# frozen_string_literal: true

class InstantRoom < ApplicationRecord
  validates :username, presence: true, length: { minimum: 2, maximum: 255 }
  validates :friendly_id, presence: true, uniqueness: true
  validates :meeting_id, presence: true, uniqueness: true

  before_validation :set_name, :set_friendly_id, :set_meeting_id, on: :create

  private

  def set_name
    self.name = "#{username}'s meeting"
  end

  # Those two methods are straight up duplicated
  # self.class.table_name is a way to make those methods work for both InstantRooms and Rooms
  def set_friendly_id
    id = SecureRandom.alphanumeric(12).downcase.scan(/.../).join('-') # Separate into 3 chunks of 4 chars
    raise if InstantRoom.exists?(friendly_id: id) # Ensure uniqueness

    self.friendly_id = id
  rescue StandardError
    retry
  end

  # Create a unique meetingId that will be used to communicate with BigBlueButton
  def set_meeting_id
    id = SecureRandom.alphanumeric(40).downcase
    raise if InstantRoom.exists?(meeting_id: id) # Ensure uniqueness

    self.meeting_id = id
  rescue StandardError
    retry
  end
end
