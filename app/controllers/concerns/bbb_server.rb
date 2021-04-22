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

require 'bigbluebutton_api'
require 'bigbluebutton_formatter'

module BbbServer
  extend ActiveSupport::Concern
  include BbbApi

  META_LISTED = "gl-listed"

  # Checks if a room is running on the BigBlueButton server.
  def room_running?(bbb_id)
    bbb_server.is_meeting_running?(bbb_id)
  end

  # Returns a list of all running meetings
  def all_running_meetings
    bbb_server.get_meetings
  end

  def get_recordings(meeting_id)
    #bbb_server.deep_get_recordings(meetingID: meeting_id)
    deep_get_recordings(meetingID: meeting_id)
  end

  def deep_get_recordings(options={})

    if options.has_key?(:meetingID)
      options[:meetingID] = options[:meetingID].join(",") if options[:meetingID].instance_of?(Array)
    end

    response = bbb_server.send_api_request(:getRecordings, options)

    logger.error response.inspect

    formatter = BigBlueButton::BigBlueButtonFormatter.new(response)
    formatter.flatten_objects(:recordings, :recording)

    logger.error response.inspect

    recordings_with_breakouts = []
    response[:recordings].each do |rec|
      logger.error rec
      recordings_with_breakouts.push(rec)
      if rec[:breakoutRooms] && rec[:breakoutRooms][:breakoutRoom]
        rec[:breakoutRooms][:breakoutRoom].each do |value|
          logger.error value
          breakout_room_options = {}
          breakout_room_options[:recordID] = value
          response_sub = bbb_server.send_api_request(:getRecordings, breakout_room_options)
          formatter_sub = BigBlueButton::BigBlueButtonFormatter.new(response_sub)
          formatter_sub.flatten_objects(:recordings, :recording)
          response_sub[:recordings].each do |rec_sub|
            recordings_with_breakouts.push(rec_sub)
          end
        end
      end
    end
    response[:recordings] = recordings_with_breakouts
    response[:recordings].each { |r| BigBlueButton::BigBlueButtonFormatter.format_recording(r) }
    response
  end

  def get_multiple_recordings(meeting_ids)
    #bbb_server.get_recordings(meetingID: meeting_ids)
    deep_get_recordings(meetingID: meeting_ids)
  end

  # Returns a URL to join a user into a meeting.
  def join_path(room, name, options = {}, uid = nil)
    # Create the meeting, even if it's running
    start_session(room, options)

    # Determine the password to use when joining.
    password = options[:user_is_moderator] ? room.moderator_pw : room.attendee_pw

    # Generate the join URL.
    join_opts = {}
    join_opts[:userID] = uid if uid
    join_opts[:join_via_html5] = true
    join_opts[:createTime] = room.last_session.to_datetime.strftime("%Q")

    join_opts[:guest] = true if options[:require_moderator_approval] && !options[:user_is_moderator] && !uid
    join_opts["userdata-bbb_force_restore_presentation_on_new_events"] = true

    if NeelzRoom.is_neelz_room?(room)
      neelz_room = NeelzRoom.convert_to_neelz_room(room)
      join_opts["userdata-bbb_show_participants_on_login"] = neelz_room.show_participants_on_login?
      join_opts["userdata-bbb_auto_swap_layout"] = true
      join_opts["userdata-bbb_hide_presentation"] = true
    else
      join_opts["userdata-bbb_display_branding_area"] = true
      join_opts["userdata-bbb_custom_style_url"] = Rails.configuration.html5_client_custom_css_url.to_json
    end

    ##test magic_cap_user ...
    mcu_prefix = Rails.configuration.mcu_prefix
    if name[0..(mcu_prefix.length-1)] === mcu_prefix
      join_opts["userdata-bbb_magic_cap_user"] = true
      if name[(mcu_prefix.length)..(mcu_prefix.length+3)] === Rails.configuration.mcu_prefix_mod
        password = room.moderator_pw
        join_opts["userdata-bbb_magic_cap_user_visible_for_herself"] = true
      else
        join_opts["userdata-bbb_magic_cap_user_visible_for_moderator"] = true
        #join_opts["userdata-bbb_enable_video"] = false
        join_opts["userdata-bbb_force_listen_only"] = true
        join_opts["userdata-bbb_auto_join_audio"] = true
        join_opts["userdata-bbb_custom_style_url"] = 'https://bbb.konkret-mafo.cloud/css/mcu_custom_style.css'
        join_opts["userdata-bbb_shortcuts"] = '%5B%5D'
        join_opts["userdata-bbb_enable_screen_sharing"] = false
      end
    end

    bbb_server.join_meeting_url(room.bbb_id, name, password, join_opts)
  end

  # Creates a meeting on the BigBlueButton server.
  def start_session(room, options = {})
    create_options = {
      record: NeelzRoom.is_neelz_room?(room) ? false.to_s : true.to_s,
      allowStartStopRecording: NeelzRoom.is_neelz_room?(room) ? false.to_s : true.to_s,
      logoutURL: options[:meeting_logout_url] || '',
      logo: NeelzRoom.is_neelz_room?(room) ? '' : Rails.configuration.html5_client_branding_logo_url.to_json,
      moderatorPW: room.moderator_pw,
      attendeePW: room.attendee_pw,
      moderatorOnlyMessage: options[:moderator_message],
      "meta_#{META_LISTED}": options[:recording_default_visibility] || false,
      "meta_bbb-origin-version": Greenlight::Application::VERSION,
      "meta_bbb-origin": Rails.configuration.instance_name,
      "meta_bbb-origin-server-name": options[:host]
    }

    create_options[:muteOnStart] = options[:mute_on_start] if options[:mute_on_start]
    create_options[:guestPolicy] = "ASK_MODERATOR" if options[:require_moderator_approval]

    # Send the create request.
    begin
      meeting = if room.presentation.attached?
        modules = BigBlueButton::BigBlueButtonModules.new
        url = rails_blob_url(room.presentation).gsub("&", "%26")
        logger.info("Support: Room #{room.uid} starting using presentation: #{url}")
        modules.add_presentation(:url, url)
        bbb_server.create_meeting(room.name, room.bbb_id, create_options, modules)
      else
        bbb_server.create_meeting(room.name, room.bbb_id, create_options)
      end

      unless meeting[:messageKey] == 'duplicateWarning'
        room.update_attributes(sessions: room.sessions + 1, last_session: DateTime.strptime(meeting[:createTime].to_s, "%Q"))
      end
    rescue BigBlueButton::BigBlueButtonException => e
      puts "BigBlueButton failed on create: #{e.key}: #{e.message}"
      raise e
    end
  end

  # Gets the number of recordings for this room
  def recording_count(bbb_id)
    bbb_server.get_recordings(meetingID: bbb_id)[:recordings].length
  end

  # Update a recording from a room
  def update_recording(record_id, meta)
    meta[:recordID] = record_id
    bbb_server.send_api_request("updateRecordings", meta)
  end

  # Deletes a recording from a room.
  def delete_recording(record_id)
    bbb_server.delete_recordings(record_id)
  end

  # Deletes all recordings associated with the room.
  def delete_all_recordings(bbb_id)
    record_ids = bbb_server.get_recordings(meetingID: bbb_id)[:recordings].pluck(:recordID)
    bbb_server.delete_recordings(record_ids) unless record_ids.empty?
  end
end
