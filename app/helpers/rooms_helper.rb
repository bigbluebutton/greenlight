# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

module RoomsHelper
  # Helper to generate the path to a Google Calendar event creation
  # It will have its title set as the room name, and the location as the URL to the room
  def google_calendar_path
    "http://calendar.google.com/calendar/r/eventedit?text=#{@room.name}&location=#{request.base_url + request.fullpath}"
  end

  def room_authentication_required
    Setting.find_or_create_by!(provider: user_settings_provider).get_value("Room Authentication") == "true" &&
      current_user.nil?
  end
end
