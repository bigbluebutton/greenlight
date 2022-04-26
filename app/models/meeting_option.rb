# frozen_string_literal: true

class MeetingOption < ApplicationRecord
  has_many :room_meeting_options, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
end
