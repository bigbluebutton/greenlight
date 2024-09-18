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

desc 'Remove dismissed or disallowed server tags from database'

task server_tags_sync: :environment do
  tag_option = MeetingOption.find_by!(name: 'serverTag')

  RoomMeetingOption.where(meeting_option: tag_option).find_each do |room_tag|
    tag_value = room_tag.value
    next if tag_value.blank?

    role_id = room_tag.room.user.role_id
    tag_invalid = false
    if Rails.configuration.server_tag_names.key?(tag_value)
      role_not_allowed = Rails.configuration.server_tag_roles.key?(tag_value) && Rails.configuration.server_tag_roles[tag_value].exclude?(role_id)
      tag_invalid = true if role_not_allowed
    else
      tag_invalid = true
    end

    if tag_invalid
      info "Clearing invalid server tag #{tag_value} for room with id #{room_tag.room}."
      room_tag.update(value: '')
    end
  rescue StandardError => e
    err "Unable to sync server tag of room:\nID: #{room_tag.room}\nError: #{e}"
  end
  success 'Successfully sanitized server tags.'
end
