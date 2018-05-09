class Room < ApplicationRecord

  before_create :set_uid

  belongs_to :user
  has_many :meetings

  def owned_by?(user)
    user.room == self
  end

  private

  # Generates a uid for the room.
  def set_uid
    digest = user.id.to_s + user.provider + user.username
    digest += user.uid unless user.uid.nil?
    self.uid = Digest::SHA1.hexdigest(digest)[0..12]
  end
end