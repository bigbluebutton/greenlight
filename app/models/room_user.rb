class RoomUser < ApplicationRecord
  belongs_to :room
  belongs_to :user

  validates :event_id, presence: true
end
