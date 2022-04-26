# frozen_string_literal: true

class Room < ApplicationRecord
  belongs_to :user
  has_many :recordings, dependent: :destroy
  has_many :room_meeting_options, dependent: :destroy

  validates :name, presence: true
  validates :friendly_id, presence: true, uniqueness: true
  validates :meeting_id, presence: true, uniqueness: true

  before_validation :set_friendly_id, :set_meeting_id, on: :create
  after_create :set_meeting_passwords

  private

  def set_friendly_id
    id = SecureRandom.alphanumeric(12).downcase.scan(/.../).join('-') # Separate into 3 chunks of 4 chars
    raise if Room.exists?(friendly_id: id) # Ensure uniqueness

    self.friendly_id = id
  rescue StandardError
    retry
  end

  # Create a unique meetingId that will be used to communicate with BigBlueButton
  def set_meeting_id
    id = SecureRandom.alphanumeric(40).downcase
    raise if Room.exists?(meeting_id: id) # Ensure uniqueness

    self.meeting_id = id
  rescue StandardError
    retry
  end

  def set_meeting_passwords
    password_option_ids = MeetingOption.password_option_ids

    password_option_ids&.each do |id|
      # TODO: Revisit the password random value.
      RoomMeetingOption.create! room_id: self.id, meeting_option_id: id, value: SecureRandom.alphanumeric(20)
    end
  end
end
