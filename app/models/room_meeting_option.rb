# frozen_string_literal: true

class RoomMeetingOption < ApplicationRecord
  belongs_to :room
  belongs_to :meeting_option
end
