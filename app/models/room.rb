# frozen_string_literal: true

class Room < ApplicationRecord
  belongs_to :user

  has_many :shared_accesses, dependent: :destroy
  has_many :shared_users, through: :shared_accesses, class_name: 'User'

  has_many :recordings, dependent: :destroy
  has_many :room_meeting_options, dependent: :destroy
  has_one :viewer_access_code_setting, lambda {
                                         joins(:meeting_option)
                                           .where(meeting_option: { name: 'glViewerAccessCode' })
                                       }, class_name: 'RoomMeetingOption', inverse_of: :room, dependent: :destroy
  has_one :moderator_access_code_setting, lambda {
                                            joins(:meeting_option).where(meeting_option: { name: 'glModeratorAccessCode' })
                                          }, class_name: 'RoomMeetingOption', inverse_of: :room, dependent: :destroy

  has_one_attached :presentation

  validates :name, presence: true
  validates :friendly_id, presence: true, uniqueness: true
  validates :meeting_id, presence: true, uniqueness: true

  before_validation :set_friendly_id, :set_meeting_id, on: :create

  after_create :create_meeting_options

  after_find :auto_generate_access_codes

  attr_accessor :shared, :active, :participants

  def self.search(input)
    return where('rooms.name ILIKE ?', "%#{input}%").to_a if input

    all.to_a
  end

  def anyone_joins_as_moderator?
    MeetingOption.get_setting_value(name: 'glAnyoneJoinAsModerator', room_id: id)&.value == 'true'
  end

  def viewer_access_code
    viewer_access_code_setting&.value
  end

  def moderator_access_code
    moderator_access_code_setting&.value
  end

  def generate_viewer_access_code
    viewer_access_code_setting&.update(value: generate_code)
  end

  def remove_viewer_access_code
    viewer_access_code_setting&.update(value: nil)
  end

  def generate_moderator_access_code
    moderator_access_code_setting&.update(value: generate_code)
  end

  def remove_moderator_access_code
    moderator_access_code_setting&.update(value: nil)
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
    access_codes_names = %w[glViewerAccessCode ModeratorAccessCode]
    access_configs = MeetingOption.access_codes_configs(provider: 'greenlight').to_h

    MeetingOption.find_each do |option|
      value = if access_codes_names.include?(option.name) && access_configs[option.name] == 'true'
                generate_code
              else
                option.default_value
              end

      RoomMeetingOption.create(room: self, meeting_option: option, value:)
    end
  end

  def generate_code
    SecureRandom.alphanumeric(6).downcase
  end

  def auto_generate_access_codes
    access_configs = MeetingOption.access_codes_configs(provider: 'greenlight').to_h

    generate_viewer_access_code if access_configs['glViewerAccessCode'] == 'true' && viewer_access_code.blank?
    generate_moderator_access_code if access_configs['glModeratorAccessCode'] == 'true' && moderator_access_code.blank?
  end
end
