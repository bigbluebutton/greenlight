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
  rolify
  include ::APIConcern
  include ::BbbApi

  attr_accessor :reset_token
  after_create :assign_default_role
  after_create :initialize_main_room

  before_save { email.try(:downcase!) }

  before_destroy :destroy_rooms

  has_many :rooms
  belongs_to :main_room, class_name: 'Room', foreign_key: :room_id, required: false

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
    # Generates a user from omniauth.
    def from_external_provider(auth)
      # Provider is the customer name if in loadbalanced config mode
      provider = Rails.configuration.loadbalanced_configuration ? auth['info']['customer'] : auth['provider']
      find_or_initialize_by(social_uid: auth['uid'], provider: provider).tap do |u|
        u.name = auth_name(auth) unless u.name
        u.username = auth_username(auth) unless u.username
        u.email = auth_email(auth)
        u.image = auth_image(auth)
        u.email_verified = true
        u.save!
      end
    end

    private

    # Provider attributes.
    def auth_name(auth)
      auth['info']['name']
    end

    def auth_username(auth)
      case auth['provider']
      when :google
        auth['info']['email'].split('@').first
      when :saml
        auth['info']['user_id']
      when :office365
        auth['info']['username']
      else
        auth['info']['nickname']
      end
    end

    def auth_email(auth)
      auth['info']['email']
    end

    def auth_image(auth)
      case auth['provider']
      when :twitter
        auth['info']['image'].gsub("http", "https").gsub("_normal", "")
      else
        auth['info']['image'] unless auth['info']['image'].nil?
      end
    end
  end

  def self.admins_search(string)
    active_database = Rails.configuration.database_configuration[Rails.env]["adapter"]
    # Postgres requires created_at to be cast to a string
    created_at_query = if active_database == "postgresql"
      "created_at::text"
    else
      "created_at"
    end

    search_query = "users.name LIKE :search OR email LIKE :search OR username LIKE :search" \
                   " OR users.#{created_at_query} LIKE :search OR provider LIKE :search"
    search_param = "%#{string}%"
    where(search_query, search: search_param)
  end

  def self.admins_order(column, direction)
    order("#{column} #{direction}")
  end

  def all_recordings(search_params = {}, ret_search_params = false)
    pag_num = Rails.configuration.pagination_number

    pag_loops = rooms.length / pag_num - 1

    res = { recordings: [] }

    (0..pag_loops).each do |i|
      pag_rooms = rooms[pag_num * i, pag_num]

      # bbb.get_recordings returns an object
      # take only the array portion of the object that is returned
      full_res = bbb.get_recordings(meetingID: pag_rooms.pluck(:bbb_id))
      res[:recordings].push(*full_res[:recordings])
    end

    last_pag_room = rooms[pag_num * (pag_loops + 1), rooms.length % pag_num]

    full_res = bbb.get_recordings(meetingID: last_pag_room.pluck(:bbb_id))
    res[:recordings].push(*full_res[:recordings])

    format_recordings(res, search_params, ret_search_params)
  end

  # Activates an account and initialize a users main room
  def activate
    update_attribute(:email_verified, true)
    update_attribute(:activated_at, Time.zone.now)
    save
  end

  def activated?
    return true unless Rails.configuration.enable_email_verification
    email_verified
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Return true if password reset link expires
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Retrives a list of all a users rooms that are not the main room, sorted by last session date.
  def secondary_rooms
    secondary = (rooms - [main_room])
    no_session, session = secondary.partition { |r| r.last_session.nil? }
    sorted = session.sort_by(&:last_session)
    sorted + no_session
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
    return true unless provider # For testing cases when provider is set to null
    return true if provider == "greenlight"
    return false unless Rails.configuration.loadbalanced_configuration
    # Proceed with fetching the provider info
    provider_info = retrieve_provider_info(provider, 'api2', 'getUserGreenlightCredentials')
    provider_info['provider'] == 'greenlight'
  end

  def activation_token
    # Create the token.
    create_reset_activation_digest(User.new_token)
  end

  def admin_of?(user)
    if Rails.configuration.loadbalanced_configuration
      if has_role? :super_admin
        id != user.id
      else
        (has_role? :admin) && (id != user.id) && (provider == user.provider) && (!user.has_role? :super_admin)
      end
    else
      ((has_role? :admin) || (has_role? :super_admin)) && (id != user.id)
    end
  end

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  private

  def create_reset_activation_digest(token)
    # Create the digest and persist it.
    self.activation_digest = User.digest(token)
    save
    token
  end

  # Destory a users rooms when they are removed.
  def destroy_rooms
    rooms.destroy_all
  end

  # Initializes a room for the user and assign a BigBlueButton user id.
  def initialize_main_room
    self.uid = "gl-#{(0...12).map { rand(65..90).chr }.join.downcase}"
    self.main_room = Room.create!(owner: self, name: I18n.t("home_room"))
    save
  end

  # Initialize the user to use the default user role
  def assign_default_role
    add_role(:user) if roles.blank?
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
end
