# frozen_string_literal: true

# Pass the room(s) to the service and it will confirm if the meeting is online or not and will return the # of participants
class RunningMeetingChecker
  def initialize(rooms:)
    @rooms = rooms
  end

  def call
    online_rooms = Array(@rooms).select { |room| room.online == true }

    online_rooms.each do |online_room|
      bbb_meeting = BigBlueButtonApi.new.get_meeting_info(meeting_id: online_room.meeting_id)
      online_room.participants = bbb_meeting[:participantCount]
    rescue BigBlueButton::BigBlueButtonException
      online_room.update(online: false)
    end
  end
end
