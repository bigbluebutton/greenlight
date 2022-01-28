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

module RoomCommon
  extend ActiveSupport::Concern

  def room_limit_exceeded(user = nil)
    user ||= current_user
    limit = @settings.get_value("Room Limit").to_i

    # Does not apply to admin or users that aren't signed in
    # 15+ option is used as unlimited
    return false if user&.has_role?(:admin) || limit == 15

    user.rooms.length >= limit
  end

  def create_room_settings_string(options)
    room_settings = {
      muteOnStart: options[:mute_on_join] == "1",
      requireModeratorApproval: options[:require_moderator_approval] == "1",
      anyoneCanStart: options[:anyone_can_start] == "1",
      joinModerator: options[:all_join_moderator] == "1",
      recording: options[:recording] == "1",
    }

    room_settings.to_json
  end

  def room_params
    params.require(:room).permit(:name, :auto_join, :mute_on_join, :access_code,
      :require_moderator_approval, :anyone_can_start, :all_join_moderator,
      :recording, :presentation, :moderator_access_code)
  end
end
