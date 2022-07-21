# frozen_string_literal: true

class MeetingOption < ApplicationRecord
  has_many :room_meeting_options, dependent: :restrict_with_exception
  has_many :rooms_configurations, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true

  def self.bbb_options(room_id:)
    MeetingOption
      .joins(:room_meeting_options)
      .where.not('name LIKE :prefix', prefix: 'gl%') # ignore gl settings
      .where(room_meeting_options: { room_id: })
      .pluck(:name, :value)
  end

  def self.get_value(name:, room_id:)
    joins(:room_meeting_options)
      .select(:value)
      .find_by(
        name:,
        room_meeting_options: { room_id: }
      )
  end
end
