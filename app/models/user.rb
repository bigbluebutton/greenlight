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

class User < ApplicationRecord
  after_create :initialize_main_room
  before_save { email.try(:downcase!) }

  before_destroy :destroy_rooms

  has_many :rooms
  belongs_to :main_room, class_name: 'Room', foreign_key: :room_id, required: false

  validates :name, length: { maximum: 256 }, presence: true
  validates :provider, presence: true
  validates :image, format: { with: /\.(png|jpg)\Z/i }, allow_blank: true
  validates :email, length: { maximum: 256 }, allow_blank: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }

  validates :password, length: { minimum: 6 }, confirmation: true, if: :greenlight_account?, on: :create

  # Bypass validation if omniauth
  validates :accepted_terms, acceptance: true,
                             unless: -> { !greenlight_account? || !Rails.configuration.terms }

  # We don't want to require password validations on all accounts.
  has_secure_password(validations: false)

  class << self
    # Generates a user from omniauth.
    def from_omniauth(auth)
      # Provider is the customer name if in loadbalanced config mode
      provider = auth['provider'] == "bn_launcher" ? auth['info']['customer'] : auth['provider']
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
      case auth['provider']
      when :microsoft_office365
        auth['info']['display_name']
      else
        auth['info']['name']
      end
    end

    def auth_username(auth)
      case auth['provider']
      when :google
        auth['info']['email'].split('@').first
      when :bn_launcher
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
        auth['info']['image'] unless auth['provider'] == :microsoft_office365
      end
    end
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
    provider == "greenlight"
  end

  private

  # Destory a users rooms when they are removed.
  def destroy_rooms
    rooms.destroy_all
  end

  # Initializes a room for the user and assign a BigBlueButton user id.
  def initialize_main_room
    self.uid = "gl-#{(0...12).map { (65 + rand(26)).chr }.join.downcase}"
    self.main_room = Room.create!(owner: self, name: I18n.t("home_room"))
    save
  end
end
