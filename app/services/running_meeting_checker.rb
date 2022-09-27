# frozen_string_literal: true

# Pass the rooms to the service and it will return the rooms with the active and participants attributes
class RunningMeetingChecker
  def initialize(rooms:)
    @rooms = rooms
  end

  def call
    active_rooms = BigBlueButtonApi.new.active_meetings
    active_rooms_hash = {}

    active_rooms.each do |active_room|
      active_rooms_hash[active_room[:meetingID]] = active_room[:participantCount]
    end

    @rooms.each do |room|
      room.active = active_rooms_hash.key?(room.meeting_id)
      room.participants = active_rooms_hash[room.meeting_id]
    end
  end
end
