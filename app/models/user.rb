class User < ApplicationRecord

  has_one :room

  class << self
    
    # Generates a user from omniauth.
    def from_omniauth(auth)
      user = find_or_initialize_by(uid: auth['uid'], provider: auth['provider'])
      user.name = send("#{auth['provider']}_name", auth)
      user.username = send("#{auth['provider']}_username", auth)
      user.email = send("#{auth['provider']}_email", auth)
      #user.token = auth['credentials']['token']

      # Create a room for the user if they don't have one.
      user.room = Room.create unless user.room
      
      user.save!
      user
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

    def google_name(auth)
      auth['info']['name']
    end

    def google_username(auth)
      auth['info']['email'].split('@').first
    end

    def google_email(auth)
      auth['info']['email']
    end

  end

end
