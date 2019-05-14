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

require 'bbb_api'

class Room < ApplicationRecord
  include ::APIConcern
  include ::BbbApi

  before_create :setup

  before_destroy :delete_all_recordings

  validates :name, presence: true

  belongs_to :owner, class_name: 'User', foreign_key: :user_id

  META_LISTED = "gl-listed"

  # Determines if a user owns a room.
  def owned_by?(user)
    return false if user.nil?
    user.rooms.include?(self)
  end

  # Checks if a room is running on the BigBlueButton server.
  def running?
    bbb.is_meeting_running?(bbb_id)
  end

  # Determines the invite path for the room.
  def invite_path
    "#{Rails.configuration.relative_url_root}/#{CGI.escape(uid)}"
  end

  # Creates a meeting on the BigBlueButton server.
  def start_session(options = {})
    create_options = {
      record: options[:meeting_recorded].to_s,
      logoutURL: options[:meeting_logout_url] || '',
      moderatorPW: moderator_pw,
      attendeePW: attendee_pw,
      moderatorOnlyMessage: options[:moderator_message],
      muteOnStart: options[:mute_on_start] || false,
      "meta_#{META_LISTED}": false,
    }

    # Send the create request.
    begin
      meeting = bbb.create_meeting(name, bbb_id, create_options)
      # Update session info.
      unless meeting[:messageKey] == 'duplicateWarning'
        update_attributes(sessions: sessions + 1, last_session: DateTime.now)
      end
    rescue BigBlueButton::BigBlueButtonException => e
      puts "BigBlueButton failed on create: #{e.key}: #{e.message}"
      raise e
    end
  end

  # Returns a URL to join a user into a meeting.
  def join_path(name, options = {}, uid = nil)
    # Create the meeting, even if it's running
    start_session(options)

    # Set meeting options.
    options[:meeting_logout_url] ||= nil
    options[:moderator_message] ||= ''
    options[:user_is_moderator] ||= false
    options[:meeting_recorded] ||= false

    return call_invalid_res unless bbb

    # Get the meeting info.
    meeting_info = bbb.get_meeting_info(bbb_id, nil)

    # Determine the password to use when joining.
    password = if options[:user_is_moderator]
      meeting_info[:moderatorPW]
    else
      meeting_info[:attendeePW]
    end

    # Generate the join URL.
    join_opts = {}
    join_opts[:userID] = uid if uid
    join_opts[:joinViaHtml5] = options[:join_via_html5] if options[:join_via_html5]

    bbb.join_meeting_url(bbb_id, name, password, join_opts)
  end

  # Notify waiting users that a meeting has started.
  def notify_waiting
    ActionCable.server.broadcast("#{uid}_waiting_channel", action: "started")
  end

  # Retrieves all the users in a room.
  def participants
    res = bbb.get_meeting_info(bbb_id, nil)
    res[:attendees].map do |att|
      User.find_by(uid: att[:userID], name: att[:fullName])
    end
  rescue BigBlueButton::BigBlueButtonException
    # The meeting is most likely not running.
    []
  end

  # Fetches all recordings for a room.
  def recordings(search_params = {}, ret_search_params = false)
    res = bbb.get_recordings(meetingID: bbb_id)

    format_recordings(res, search_params, ret_search_params)
  end

  # Fetches a rooms public recordings.
  def public_recordings(search_params = {}, ret_search_params = false)
    search, order_col, order_dir, recs = recordings(search_params, ret_search_params)
    [search, order_col, order_dir, recs.select { |r| r[:metadata][:"gl-listed"] == "true" }]
  end

  def update_recording(record_id, meta)
    meta[:recordID] = record_id
    bbb.send_api_request("updateRecordings", meta)
  end

  # Deletes a recording from a room.
  def delete_recording(record_id)
    bbb.delete_recordings(record_id)
  end

  private

  # Generates a uid for the room and BigBlueButton.
  def setup
    self.uid = random_room_uid
    self.bbb_id = Digest::SHA1.hexdigest(Rails.application.secrets[:secret_key_base] + Time.now.to_i.to_s).to_s
    self.moderator_pw = RandomPassword.generate(length: 12)
    self.attendee_pw = RandomPassword.generate(length: 12)
  end

  # Deletes all recordings associated with the room.
  def delete_all_recordings
    record_ids = recordings.map { |r| r[:recordID] }
    delete_recording(record_ids) unless record_ids.empty?
  end

  # Generates a three character uid chunk.
  def uid_chunk
    charset = ("a".."z").to_a - %w(b i l o s) + ("2".."9").to_a - %w(5 8)
    (0...3).map { charset.to_a[rand(charset.size)] }.join
  end

  # Generates a random room uid that uses the users name.
  def random_room_uid
    [owner.name_chunk, uid_chunk, uid_chunk].join('-').downcase
  end
end
