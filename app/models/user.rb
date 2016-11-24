class User < ApplicationRecord

  before_create :set_encrypted_id

  def self.from_omniauth(auth_hash)
    user = find_or_initialize_by(uid: auth_hash['uid'], provider: auth_hash['provider'])
    user.username = self.send("#{auth_hash['provider']}_username", auth_hash) rescue nil
    user.name = auth_hash['info']['name']
    user.save!
    user
  end

  def self.twitter_username(auth_hash)
    auth_hash['info']['nickname']
  end

  def self.google_username(auth_hash)
    auth_hash['info']['email'].split('@').first
  end

  def room_url
    "/rooms/#{encrypted_id}"
  end

  def set_encrypted_id
    self.encrypted_id = "#{username[0..1]}-#{Digest::SHA1.hexdigest(uid+provider)[0..7]}"
  end
end
