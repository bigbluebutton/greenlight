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

require 'bigbluebutton_api'

class BigBlueButtonApi
  def initialize; end

  # Sets a BigBlueButtonApi object for interacting with the API.
  def bbb_server
    # TODO: Amir - Protect the BBB secret.
    @bbb_server ||= BigBlueButton::BigBlueButtonApi.new(Rails.configuration.bigbluebutton_endpoint, Rails.configuration.bigbluebutton_secret, '1.8')
  end

  # Start a meeting for a specific room and returns the join URL.
  def start_meeting(room:, options: {}, presentation_url: nil)
    if presentation_url.present?
      modules = BigBlueButton::BigBlueButtonModules.new
      modules.add_presentation(:url, presentation_url)
      bbb_server.create_meeting(room.name, room.meeting_id, options, modules)
    else
      bbb_server.create_meeting(room.name, room.meeting_id, options)
    end
  end

  def join_meeting(room:, role:, name: nil, avatar_url: nil)
    bbb_server.join_meeting_url(
      room.meeting_id,
      name,
      '', # empty password -> use the role passed ing
      {
        role:,
        avatarURL: avatar_url,
        createTime: room.last_session&.to_datetime&.strftime('%Q')
      }.compact
    )
  end

  def meeting_running?(room:)
    bbb_server.is_meeting_running?(room.meeting_id)
  end

  def active_meetings
    bbb_server.get_meetings[:meetings]
  end

  def get_meeting_info(meeting_id:)
    bbb_server.get_meeting_info(meeting_id, nil)
  end

  # Retrieve the recordings that belong to room with given record_id
  def get_recording(record_id:)
    bbb_server.get_recordings(recordID: record_id)[:recordings][0]
  end

  # Retrieve the recordings that belong to room with given meeting_id
  def get_recordings(meeting_ids:)
    bbb_server.get_recordings(meetingID: meeting_ids)
  end

  # Delete the recording(s) with given record_ids
  def delete_recordings(record_ids:)
    bbb_server.delete_recordings(record_ids)
  end

  # Sets publish (true/false) for recording(s) with given record_id(s)
  def publish_recordings(record_ids:, publish:)
    bbb_server.publish_recordings(record_ids, publish)
  end

  def update_recordings(record_id:, meta_hash:)
    bbb_server.update_recordings(record_id, {}, meta_hash)
  end

  # Decodes the JWT using the BBB secret as key (Used in Recording Ready Callback)
  def decode_jwt(token)
    JWT.decode token, Rails.configuration.bigbluebutton_secret, true, { algorithm: 'HS256' }
  end
end
