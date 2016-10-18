class User < ApplicationRecord

  def self.from_omniauth(auth_hash)
    user = find_or_create_by(uid: auth_hash['uid'], provider: auth_hash['provider'])
    user.username = self.send("#{auth_hash['provider']}_username", auth_hash) rescue nil
    user.name = auth_hash['info']['name']
    user.save!
    user
  end

  def self.twitter_username(auth_hash)
    auth_hash['info']['nickname']
  end

  def room_url
    "/rooms/#{username}"
  end
end
