

class User < ApplicationRecord

  before_create :set_encrypted_id
  has_attached_file :background
  validates_attachment :background,
                       :content_type => { :content_type => ["image/jpg", "image/jpeg", "image/gif", "image/png"] }

  def self.from_omniauth(auth_hash)
    user = find_or_initialize_by(uid: auth_hash['uid'], provider: auth_hash['provider'])
    user.username = self.send("#{auth_hash['provider']}_username", auth_hash) rescue nil
    user.email = self.send("#{auth_hash['provider']}_email", auth_hash) rescue nil
    user.name = auth_hash['info']['name']
    user.token = auth_hash['credentials']['token'] rescue nil
    user.save!
    user
  end

  def self.twitter_username(auth_hash)
    auth_hash['info']['nickname']
  end

  def self.twitter_email(auth_hash)
    auth_hash['info']['email']
  end

  def self.google_username(auth_hash)
    auth_hash['info']['email'].split('@').first
  end

  def self.google_email(auth_hash)
    auth_hash['info']['email']
  end

  def self.ldap_username(auth_hash)
    auth_hash['info']['nickname']
  end
  
  def self.ldap_email(auth_hash)
    auth_hash['info']['email']
  end

  def set_encrypted_id
    self.encrypted_id = "#{username[0..1]}-#{Digest::SHA1.hexdigest(uid+provider)[0..7]}"
  end
end
