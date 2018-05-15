class Room < ApplicationRecord

  before_create :set_uid

  belongs_to :user
  has_one :meeting

  # Determines if a user owns a room.
  def owned_by?(user)
    return false if user.nil?
    user.room == self
  end

  private

  # Generates a uid for the room.
  def set_uid
    digest = user.id.to_s + user.provider + user.username
    digest += user.uid unless user.uid.nil?

    self.uid = [user.name.split(' ').first.downcase, Digest::SHA1.hexdigest(digest)[0..7]].join('-')
  end
end