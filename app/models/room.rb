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

class Room < ApplicationRecord
  before_create :setup

  before_destroy :delete_all_recordings

  validates :name, presence: true

  belongs_to :owner, class_name: 'User', foreign_key: :user_id

  RETURNCODE_SUCCESS = "SUCCESS"
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
      moderatorPW: random_password(12),
      attendeePW: random_password(12),
      moderatorOnlyMessage: options[:moderator_message],
      "meta_#{META_LISTED}": false,
    }

    # Update session info.
    update_attributes(sessions: sessions + 1, last_session: DateTime.now)

    # Send the create request.
    begin
      bbb.create_meeting(name, bbb_id, create_options)
    rescue BigBlueButton::BigBlueButtonException => exc
      puts "BigBlueButton failed on create: #{exc.key}: #{exc.message}"
      raise exc
    end
  end

  # Returns a URL to join a user into a meeting.
  def join_path(name, options = {}, uid = nil)
    # Create the meeting if it isn't running.
    start_session(options) unless running?

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
  def recordings
    res = bbb.get_recordings(meetingID: bbb_id)
    # Format playbacks in a more pleasant way.
    res[:recordings].each do |r|
      next if r.key?(:error)
      r[:playbacks] = if !r[:playback] || !r[:playback][:format]
        []
      elsif r[:playback][:format].is_a?(Array)
        r[:playback][:format]
      else
        [r[:playback][:format]]
      end

      r.delete(:playback)
    end

    res[:recordings].sort_by { |rec| rec[:endTime] }.reverse
  end

  # Fetches a rooms public recordings.
  def public_recordings
    recordings.select { |r| r[:metadata][:"gl-listed"] == "true" }
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

  def bbb_endpoint
    Rails.configuration.bigbluebutton_endpoint
  end

  def bbb_secret
    Rails.configuration.bigbluebutton_secret
  end

  # Sets a BigBlueButtonApi object for interacting with the API.
  def bbb
    @bbb ||= if Rails.configuration.loadbalanced_configuration
      lb_user = retrieve_loadbalanced_credentials(owner.provider)
      BigBlueButton::BigBlueButtonApi.new(remove_slash(lb_user["apiURL"]), lb_user["secret"], "0.8")
    else
      BigBlueButton::BigBlueButtonApi.new(remove_slash(bbb_endpoint), bbb_secret, "0.8")
    end
  end

  # Generates a uid for the room and BigBlueButton.
  def setup
    self.uid = random_room_uid
    self.bbb_id = Digest::SHA1.hexdigest(Rails.application.secrets[:secret_key_base] + Time.now.to_i.to_s).to_s
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

  # Rereives the loadbalanced BigBlueButton credentials for a user.
  def retrieve_loadbalanced_credentials(provider)
    # Include Omniauth accounts under the Greenlight provider.
    provider = "greenlight" if Rails.configuration.providers.include?(provider.to_sym)

    # Build the URI.
    uri = encode_bbb_url(
      Rails.configuration.loadbalancer_endpoint + "getUser",
      Rails.configuration.loadbalancer_secret,
      name: provider
    )

    # Make the request.
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    response = http.get(uri.request_uri)

    unless response.is_a?(Net::HTTPSuccess)
      raise "Error retrieving provider credentials: #{response.code} #{response.message}"
    end

    # Parse XML.
    doc = XmlSimple.xml_in(response.body, 'ForceArray' => false)

    # Return the user credentials if the request succeeded on the loadbalancer.
    return doc['user'] if doc['returncode'] == RETURNCODE_SUCCESS

    raise "User with provider #{provider} does not exist." if doc['messageKey'] == "noSuchUser"
    raise "API call #{url} failed with #{doc['messageKey']}."
  end

  # Builds a request to retrieve credentials from the load balancer.
  def encode_bbb_url(base_url, secret, params)
    encoded_params = OAuth::Helper.normalize(params)
    string = "getUser" + encoded_params + secret
    checksum = OpenSSL::Digest.digest('sha1', string).unpack("H*").first

    URI.parse("#{base_url}?#{encoded_params}&checksum=#{checksum}")
  end

  # Removes trailing forward slash from a URL.
  def remove_slash(s)
    s.nil? ? nil : s.chomp("/")
  end

  # Generates a random password for a meeting.
  def random_password(length)
    charset = ("a".."z").to_a + ("A".."Z").to_a
    ((0...length).map { charset[rand(charset.length)] }).join
  end
end
