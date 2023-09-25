# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
  validates :voice_bridge, uniqueness: true
  validates :presentation,
            content_type: Rails.configuration.uploads[:presentations][:formats],
            size: { less_than: Rails.configuration.uploads[:presentations][:max_size] }

  validates :name, length: { minimum: 2, maximum: 255 }
  validates :recordings_processing, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :set_friendly_id, :set_meeting_id, :set_voice_brige, on: :create
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
    configs = RoomsConfiguration.joins(:meeting_option).where(provider: user.provider).pluck(:name, :value).to_h

    MeetingOption.all.find_each do |option|
      value = if %w[true default_enabled].include? configs[option.name]
                option.true_value
              else
                option.default_value
              end
      RoomMeetingOption.create(room: self, meeting_option: option, value:)
    end
  end

  def public_recordings
    recordings.where(visibility: [Recording::VISIBILITIES[:public], Recording::VISIBILITIES[:public_protected]])
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

  # Create unique pin for voice brige max 10^5 - 10000 unique ids
  def set_voice_brige
    if Rails.application.config.voice_bridge_phone_number != nil
      id = SecureRandom.random_number((10.pow(5)) - 1)
      raise if Room.exists?(voice_bridge: id) || id < 10000
    
      self.voice_bridge = id
    end
  rescue StandardError
    retry
  end
end
