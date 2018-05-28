class User < ApplicationRecord

  after_create :initialize_room
  before_save { email.downcase! unless email.nil? }

  has_one :room

  validates :name, length: { maximum: 24 }, presence: true
  validates :username, presence: true
  validates :provider, presence: true
  validates :email, length: { maximum: 60 }, allow_nil: true,
                    uniqueness: { case_sensitive: false },
                    format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }

  validates :password, length: { minimum: 6 }, allow_nil: true

  # We don't want to run the validations because they require a user
  # to have a password. Users who authenticate via omniauth won't.
  has_secure_password(validations: false)

  class << self
    
    # Generates a user from omniauth.
    def from_omniauth(auth)
      user = find_or_initialize_by(uid: auth['uid'], provider: auth['provider'])
      user.name = send("#{auth['provider']}_name", auth)
      user.username = send("#{auth['provider']}_username", auth)
      user.email = send("#{auth['provider']}_email", auth)
      user.image = send("#{auth['provider']}_image", auth)
      user.save!
      user
    end

    # Generates a user from a trusted launcher.
    def from_launch(auth)

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
      auth['info']['image']
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
      auth['info']['picture']
    end
  end

  def subtitle
    case provider
    when "greenlight", "google", "twitter"
      "User"
    else
      "Unknown"
    end
  end

  def firstname
    name.split(' ').first
  end

  private

  # Initializes a room for the user.
  def initialize_room
    room = Room.create(user_id: self.id)
    Meeting.create(room_id: room.id, name: "Example")
  end
end
