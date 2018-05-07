class Room < ApplicationRecord

  before_create :set_uid

  belongs_to :user
  has_many :meetings

  def owned_by?(user)
    user.room == self
  end

  private

  def set_uid
    self.uid = Digest::SHA1.hexdigest(user.uid + user.provider + user.username)[0..12]
  end
end