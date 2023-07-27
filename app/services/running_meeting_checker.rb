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

# Pass the room(s) to the service and it will confirm if the meeting is online or not and will return the # of participants
class RunningMeetingChecker
  def initialize(rooms:)
    @rooms = rooms
  end

  def call
    @rooms.each do |room|
      next unless room.online

      begin
        bbb_meeting = BigBlueButtonApi.new(provider: room.user.provider).get_meeting_info(meeting_id: room.meeting_id)
        room.participants = bbb_meeting[:participantCount]
      rescue BigBlueButton::BigBlueButtonException
        room.update(online: false)
      end
    end
  end
end
