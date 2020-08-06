# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

require 'bbb_api'

class User < ApplicationRecord
  include Deleteable

  after_create :setup_user

  before_save { email.try(:downcase!) }

  before_destroy :destroy_rooms

  has_many :rooms
  has_many :shared_access
  belongs_to :main_room, class_name: 'Room', foreign_key: :room_id, required: false

  has_and_belongs_to_many :roles, join_table: :users_roles # obsolete

  belongs_to :role, required: false

  validates :name, length: { maximum: 256 }, presence: true
  validates :provider, presence: true
  validate :check_if_email_can_be_blank
  validates :email, length: { maximum: 256 }, allow_blank: true,
                    uniqueness: { case_sensitive: false, scope: :provider },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }

  validates :password, length: { minimum: 6 }, confirmation: true, if: :greenlight_account?, on: :create

  # Bypass validation if omniauth
  validates :accepted_terms, acceptance: true,
                             unless: -> { !greenlight_account? || !Rails.configuration.terms }

  # We don't want to require password validations on all accounts.
  has_secure_password(validations: false)

  class << self
    include AuthValues

    # Generates a user from omniauth.
    def from_omniauth(auth)
      # Provider is the customer name if in loadbalanced config mode
      provider = auth['provider'] == "bn_launcher" ? auth['info']['customer'] : auth['provider']
      find_or_initialize_by(social_uid: auth['uid'], provider: provider).tap do |u|
        u.name = auth_name(auth) unless u.name
        u.username = auth_username(auth) unless u.username
        u.email = auth_email(auth)
        u.image = auth_image(auth) unless u.image
        auth_roles(u, auth)
        u.email_verified = true
        u.save!
      end
    end
  end

  def self.admins_search(string)
    return all if string.blank?

    active_database = Rails.configuration.database_configuration[Rails.env]["adapter"]
    # Postgres requires created_at to be cast to a string
    created_at_query = if active_database == "postgresql"
      "created_at::text"
    else
      "created_at"
    end

    search_query = "users.name LIKE :search OR email LIKE :search OR username LIKE :search" \
                  " OR users.#{created_at_query} LIKE :search OR users.provider LIKE :search" \
                  " OR roles.name LIKE :search"

    search_param = "%#{sanitize_sql_like(string)}%"
    where(search_query, search: search_param)
  end

  def self.admins_order(column, direction)
    # Arel.sql to avoid sql injection
    order(Arel.sql("users.#{column} #{direction}"))
  end

  # Returns a list of rooms ordered by last session (with nil rooms last)
  def ordered_rooms
    [main_room] + rooms.where.not(id: main_room.id).order(Arel.sql("last_session IS NULL, last_session desc"))
  end

  # Activates an account and initialize a users main room
  def activate
    set_role :user if role_id.nil?
    update_attributes(email_verified: true, activated_at: Time.zone.now, activation_digest: nil)
  end

  def activated?
    Rails.configuration.enable_email_verification ? email_verified : true
  end

  def self.hash_token(token)
    Digest::SHA2.hexdigest(token)
  end

  # Sets the password reset attributes.
  def create_reset_digest
    new_token = SecureRandom.urlsafe_base64
    update_attributes(reset_digest: User.hash_token(new_token), reset_sent_at: Time.zone.now)
    new_token
  end

  def create_activation_token
    new_token = SecureRandom.urlsafe_base64
    update_attributes(activation_digest: User.hash_token(new_token))
    new_token
  end

  # Return true if password reset link expires
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Retrieves a list of rooms that are shared with the user
  def shared_rooms
    Room.where(id: shared_access.pluck(:room_id))
  end

  def name_chunk
    charset = ("a".."z").to_a - %w(b i l o s) + ("2".."9").to_a - %w(5 8)
    chunk = name.parameterize[0...3]
    if chunk.empty?
      chunk + (0...3).map { charset.to_a[rand(charset.size)] }.join
    elsif chunk.length == 1
      chunk + (0...2).map { charset.to_a[rand(charset.size)] }.join
    elsif chunk.length == 2
      chunk + (0...1).map { charset.to_a[rand(charset.size)] }.join
    else
      chunk
    end
  end

  def greenlight_account?
    social_uid.nil?
  end

  def admin_of?(user, permission)
    has_correct_permission = role.get_permission(permission) && id != user.id

    return has_correct_permission unless Rails.configuration.loadbalanced_configuration
    return id != user.id if has_role? :super_admin
    has_correct_permission && provider == user.provider && !user.has_role?(:super_admin)
  end

  # role functions
  def set_role(role) # rubocop:disable Naming/AccessorMethodName
    return if has_role?(role)

    new_role = Role.find_by(name: role, provider: role_provider)

    return if new_role.nil?

    create_home_room if main_room.nil? && new_role.get_permission("can_create_rooms")

    update_attribute(:role, new_role)

    new_role
  end

  # This rule is disabled as the function name must be has_role?
  def has_role?(role_name) # rubocop:disable Naming/PredicateName
    role&.name == role_name.to_s
  end

  def self.with_role(role)
    User.includes(:role).where(roles: { name: role })
  end

  def self.without_role(role)
    User.includes(:role).where.not(roles: { name: role })
  end

  def create_home_room
    room = Room.create!(owner: self, name: I18n.t("home_room"))
    update_attributes(main_room: room)
  end

  private

  # Destory a users rooms when they are removed.
  def destroy_rooms
    rooms.destroy_all
  end

  def setup_user
    # Initializes a room for the user and assign a BigBlueButton user id.
    id = "gl-#{(0...12).map { rand(65..90).chr }.join.downcase}"

    update_attributes(uid: id)

    # Initialize the user to use the default user role
    role_provider = Rails.configuration.loadbalanced_configuration ? provider : "greenlight"

    Role.create_default_roles(role_provider) if Role.where(provider: role_provider).count.zero?
  end

  def check_if_email_can_be_blank
    if email.blank?
      if Rails.configuration.loadbalanced_configuration && greenlight_account?
        errors.add(:email, I18n.t("errors.messages.blank"))
      elsif provider == "greenlight"
        errors.add(:email, I18n.t("errors.messages.blank"))
      end
    end
  end

  def role_provider
    Rails.configuration.loadbalanced_configuration ? provider : "greenlight"
  end
end
