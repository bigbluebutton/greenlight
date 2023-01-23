# frozen_string_literal: true

class MeetingOption < ApplicationRecord
  has_many :room_meeting_options, dependent: :restrict_with_exception
  has_many :rooms_configurations, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true

  def self.get_setting_value(name:, room_id:)
    joins(:room_meeting_options)
      .select(:value)
      .find_by(
        name:,
        room_meeting_options: { room_id: }
      )
  end

  def self.get_config_value(name:, provider:)
    joins(:rooms_configurations)
      .where(
        name:,
        rooms_configurations: { provider: }
      )
      .pluck(:name, :value)
      .to_h
  end

  def true_value
    if name.ends_with? 'AccessCode'
      SecureRandom.alphanumeric(6).downcase
    elsif name == 'guestPolicy'
      'ASK_MODERATOR'
    else
      'true'
    end
  end
end
