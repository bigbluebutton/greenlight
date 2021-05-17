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
    # current_list = @room.shared_users.pluck(:id)
    # Get the list of user who have shared room acccess
    guest_list = (User.where(id: (@room.shared_users.pluck(:id)))).pluck(:email)
    guest_list_url = ""
    urll = guest_list.each do |email|
      guest_list_url  = guest_list_url + "&add=" + email
    end
  return ("http://calendar.google.com/calendar/r/eventedit?text=#{@room.name}&location=#{request.base_url + request.fullpath}#{guest_list_url}")
  end

  def microsoft_calendar_path
    # current_list = @room.shared_users.pluck(:id)
    # Get the list of user who have shared room acccess
    guest_list = (User.where(id: (@room.shared_users.pluck(:id)))).pluck(:email)
    guest_list_url = ""
    urll = guest_list.each do |email|
      guest_list_url  = guest_list_url + "," + email
    end
    return ("https://outlook.live.com/owa/?path=/calendar/action/compose&rru=addevent&subject=#{@room.name}&body=#{request.base_url + request.fullpath}&location=#{request.base_url + request.fullpath}&to=#{guest_list_url}")
  end

  def room_authentication_required
    @settings.get_value("Room Authentication") == "true" &&
      current_user.nil?
  end

  def current_room_exceeds_limit(room)
    # Get how many rooms need to be deleted to reach allowed room number
    limit = @settings.get_value("Room Limit").to_i

    return false if current_user&.has_role?(:admin) || limit == 15

    @diff = current_user.rooms.count - limit
    @diff.positive? && current_user.rooms.pluck(:id).index(room.id) + 1 > limit
  end

  def room_configuration(name)
    @settings.get_value(name)
  end

  def preupload_allowed?
    @settings.get_value("Preupload Presentation") == "true"
  end

  def display_joiner_consent
    # If the require consent setting is checked, then check the room setting, else, set to false
    if recording_consent_required?
      room_setting_with_config("recording")
    else
      false
    end
  end

  # Array of recording formats not to show for public recordings
  def hidden_format_public
    ENV.fetch("HIDDEN_FORMATS_PUBLIC", "").split(",")
  end

  # Returns the total number of visibile rooms for the current user
  def total_room_count(user)
    total = user.rooms.length
    total += user.shared_rooms.length if shared_access_allowed
    total
  end
end
