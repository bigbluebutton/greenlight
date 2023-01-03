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
  validates :presentation,
            content_type: %i[.doc .docx .ppt .pptx .pdf .xls .xlsx .txt .rtf .odt .ods .odp .odg .odc .odi .jpg .jpeg .png],
            size: { less_than: 30.megabytes }

  validates :name, length: { minimum: 2, maximum: 255 }
  validates :recordings_processing, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :set_friendly_id, :set_meeting_id, on: :create
  after_create :create_meeting_options

  attr_accessor :shared, :active, :participants

  scope :with_provider, ->(current_provider) { where(user: { provider: current_provider }) }

  def self.search(input)
    return where('rooms.name ILIKE ?', "%#{input}%") if input

    all
  end

  def self.admin_search(input)
    return where('rooms.name ILIKE :input OR users.name ILIKE :input OR rooms.friendly_id ILIKE :input', input: "%#{input}%") if input

    all
  end

  def get_setting(name:)
    room_meeting_options.joins(:meeting_option)
                        .find_by(meeting_option: { name: })
  end

  # Autocreate all meeting options using the default values
  def create_meeting_options
    configs = MeetingOption.get_config_value(name: %w[glViewerAccessCode glModeratorAccessCode], provider: user.provider)
    configs = configs.select { |_k, v| v == 'true' }

    MeetingOption.all.find_each do |option|
      value = configs.key?(option.name) ? SecureRandom.alphanumeric(6).downcase : option.default_value
      RoomMeetingOption.create(room: self, meeting_option: option, value:)
    end
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
end
