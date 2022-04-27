# frozen_string_literal: true

class RoomMeetingOption < ApplicationRecord
  belongs_to :room
  belongs_to :meeting_option

  delegate :name, to: :meeting_option

  scope :bbb_option_names_values, -> { includes(:meeting_option).where.not('name LIKE ?', 'gl%').pluck(:name, :value) }
end
