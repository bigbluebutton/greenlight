class User < ApplicationRecord

  after_create :initialize_main_room
  before_save { email.downcase! unless email.nil? }

  has_many :rooms
  belongs_to :main_room, class_name: 'Room', foreign_key: :room_id, required: false

  validates :name, length: { maximum: 24 }, presence: true
  validates :provider, presence: true
  validates :image, format: {with: /\.(png|jpg)\Z/i}, allow_blank: true
  validates :email, length: { maximum: 60 }, allow_blank: true,
                    uniqueness: { case_sensitive: false },
                    format: {with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }

  validates :password, length: { minimum: 6 }, presence: true, confirmation: true, allow_blank: true, if: :greenlight_account?

  # We don't want to require password validations on all accounts.
  has_secure_password(validations: false)

  class << self
    
    # Generates a user from omniauth.
    def from_omniauth(auth)
      user = find_or_initialize_by(
        social_uid: auth['uid'],
        provider: auth['provider']
      )

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
      auth['info']['image'].gsub!("_normal", "")
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
  end

  # Retrives a list of all a users rooms that are not the main room, sorted by last session date.
  def secondary_rooms
    secondary = (rooms - [main_room])
    no_session, session = secondary.partition do |r| r.last_session.nil? end
    sorted = session.sort_by do |r| r.last_session end
    session + no_session
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
    self.save
  end
end
