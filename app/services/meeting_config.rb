# frozen_string_literal: true

require 'bigbluebutton_api'

class MeetingConfig
  # UI only meeting options (These options has no use to be stored in the db).
  UI_OPTION_NAMES = ['glJoinOnStart'].freeze

  def initialize(room:, options:)
    @room = room
    @options = options
  end

  def create_meeting_options!
    meeting_options_ids = MeetingOption.public_option_names_ids.to_h
    public_options = MeetingOption.public_option_names

    @options&.each do |option, value|
      str_option = option.to_s
      str_value = value.to_s

      next unless public_options.include? str_option # Accept relevant options to the backend only.

      RoomMeetingOption.create! room_id: @room.id, meeting_option_id: meeting_options_ids[str_option], value: str_value
    end
  end

  # Class methods
  class << self
    # All of the expected meeting options that will be set by the room owner.
    def option_names
      MeetingOption.public_option_names + UI_OPTION_NAMES
    end
  end
end
