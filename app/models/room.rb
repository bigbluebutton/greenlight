# frozen_string_literal: true

class Room < ApplicationRecord
  belongs_to :user

  has_many :shared_accesses, dependent: :destroy
  has_many :shared_users, through: :shared_accesses, class_name: 'User'

  has_many :recordings, dependent: :destroy
  has_many :room_meeting_options, dependent: :destroy

  has_one_attached :presentation

  validates :name, presence: true
  validates :friendly_id, presence: true, uniqueness: true
  validates :meeting_id, presence: true, uniqueness: true

  before_validation :set_friendly_id, :set_meeting_id, on: :create

  after_create :create_meeting_options
  after_create :generate_viewer_access_code, if: :auto_generate_viewer_access_code?
  after_create :generate_moderator_access_code, if: :auto_generate_moderator_access_code?

  after_find :generate_viewer_access_code, if: :auto_generate_viewer_access_code?
  after_find :generate_moderator_access_code, if: :auto_generate_moderator_access_code?

  attr_accessor :shared, :active, :participants

  def self.search(input)
    return where('rooms.name ILIKE ?', "%#{input}%").to_a if input

    all.to_a
  end

  def anyone_joins_as_moderator?
    MeetingOption.get_setting_value(name: 'glAnyoneJoinAsModerator', room_id: id)&.value == 'true'
  end

  def viewer_access_code
    get_setting(name: 'glViewerAccessCode')&.value
  end

  def moderator_access_code
    get_setting(name: 'glModeratorAccessCode')&.value
  end

  def generate_viewer_access_code
    get_setting(name: 'glViewerAccessCode')&.update(value: generate_code)
  end

  def remove_viewer_access_code
    get_setting(name: 'glViewerAccessCode')&.update(value: nil)
  end

  def generate_moderator_access_code
    get_setting(name: 'glModeratorAccessCode')&.update(value: generate_code)
  end

  def remove_moderator_access_code
    get_setting(name: 'glModeratorAccessCode')&.update(value: nil)
  end

  def get_setting(name:)
    room_meeting_options.joins(:meeting_option)
                        .find_by(meeting_option: { name: })
  end

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

  # Autocreate all meeting options using the default values
  def create_meeting_options
    MeetingOption.all.find_each do |option|
      RoomMeetingOption.create(room: self, meeting_option: option, value: option.default_value)
    end
  end

  def generate_code
    SecureRandom.alphanumeric(6).downcase
  end

  def auto_generate_viewer_access_code?
    config = MeetingOption.get_config_value(name: 'glViewerAccessCode', provider: 'greenlight')&.value

    viewer_access_code.blank? && config == 'true'
  end

  def auto_generate_moderator_access_code?
    config = MeetingOption.get_config_value(name: 'glModeratorAccessCode', provider: 'greenlight')&.value

    moderator_access_code.blank? && config == 'true'
  end
end
