# frozen_string_literal: true

class User < ApplicationRecord
  after_create :initialize_main_room
  before_save { email.try(:downcase!) }

  has_many :rooms
  belongs_to :main_room, class_name: 'Room', foreign_key: :room_id, required: false

  validates :name, length: { maximum: 24 }, presence: true
  validates :provider, presence: true
  validates :image, format: { with: /\.(png|jpg)\Z/i }, allow_blank: true
  validates :email, length: { maximum: 60 }, allow_blank: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }

  validates :password, length: { minimum: 6 }, confirmation: true, if: :greenlight_account?

  # We don't want to require password validations on all accounts.
  has_secure_password(validations: false)

  class << self
    # Generates a user from omniauth.
    def from_omniauth(auth)
      find_or_initialize_by(social_uid: auth['uid'], provider: auth['provider']).tap do |u|
        u.name = send("#{auth['provider']}_name", auth)
        u.username = send("#{auth['provider']}_username", auth)
        u.email = send("#{auth['provider']}_email", auth)
        u.image = send("#{auth['provider']}_image", auth)
        u.save!
      end
    end

    private

    # Provider attributes.
    def twitter_name(auth)
      auth['info']['name']
    end

    def twitter_username(auth)
      auth['info']['nickname']
    end

    def twitter_email(auth)
      auth['info']['email']
    end

    def twitter_image(auth)
      auth['info']['image'].gsub("http", "https").gsub("_normal", "")
    end

    def google_name(auth)
      auth['info']['name']
    end

    def google_username(auth)
      auth['info']['email'].split('@').first
    end

    def google_email(auth)
      auth['info']['email']
    end

    def google_image(auth)
      auth['info']['image']
    end

    def bn_launcher_name(auth)
      auth['user_info']['username']
    end

    def bn_launcher_username(auth)
      auth['user_info']['username']
    end

    def bn_launcher_email(auth)
      auth['user_info']['email']
    end

    def bn_launcher_image(auth)
      ""
    end
  end

  # Retrives a list of all a users rooms that are not the main room, sorted by last session date.
  def secondary_rooms
    secondary = (rooms - [main_room])
    no_session, session = secondary.partition { |r| r.last_session.nil? }
    sorted = session.sort_by(&:last_session)
    sorted + no_session
  end

  def firstname
    name.split(' ').first
  end

  def greenlight_account?
    provider == "greenlight"
  end

  private

  # Initializes a room for the user and assign a BigBlueButton user id.
  def initialize_main_room
    self.uid = "gl-#{(0...12).map { (65 + rand(26)).chr }.join.downcase}"
    self.main_room = Room.create!(owner: self, name: firstname + "'s Room")
    save
  end
end
