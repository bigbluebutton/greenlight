# frozen_string_literal: true

class MeetingOption < ApplicationRecord
  has_many :room_meeting_options, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true

  def self.bbb_options(room_id:)
    MeetingOption
      .joins(:room_meeting_options)
      .where.not('name LIKE :prefix', prefix: 'gl%') # ignore gl settings
      .where(room_meeting_options: { room_id: })
      .pluck(:name, :value)
  end
end
