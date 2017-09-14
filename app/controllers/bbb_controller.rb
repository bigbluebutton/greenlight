# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2016 BigBlueButton Inc. and by respective authors (see below).
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

class BbbController < ApplicationController
  include BbbApi

  before_action :authorize_recording_owner!, only: [:update_recordings, :delete_recordings]
  before_action :load_and_authorize_room_owner!, only: [:end]

  skip_before_action :verify_authenticity_token, only: :callback

  # GET /:resource/:id/join
  # GET /:resource/:room_id/:id/join
  def join
    if params[:name].blank?
      return render_bbb_response(
        messageKey: "missing_parameter",
        message: "user name was not included",
        status: :unprocessable_entity
      )
    elsif params[:name].size > user_name_limit
      return render_bbb_response(
        messageKey: "invalid_parameter",
        message: "user name is too long",
        status: :unprocessable_entity
      )
    elsif params[:id].size > meeting_name_limit
      return render_bbb_response(
        messageKey: "invalid_parameter",
        message: "meeting name is too long",
        status: :unprocessable_entity
      )
    else
      if params[:room_id]
        user = User.find_by encrypted_id: params[:room_id]
        if !user
          return render_bbb_response(
            messageKey: "not_found",
            message: "User Not Found",
            status: :not_found
          )
        end

        meeting_id = "#{params[:room_id]}-#{params[:id]}"
        meeting_name = params[:id]
        meeting_path = "#{URI.encode(params[:room_id])}/#{URI.encode(params[:id]).gsub('/','%2F')}"
      else
        user = User.find_by encrypted_id: params[:id]
        meeting_id = params[:id]
        meeting_path = URI.encode(meeting_id).gsub('/','%2F')
      end

      options = if user
        {
          wait_for_moderator: true,
          meeting_recorded: true,
          meeting_name: meeting_name,
          room_owner: params[:room_id],
          user_is_moderator: current_user == user
        }
      else
        {
          user_is_moderator: true
        }
      end

      base_url = "#{request.base_url}#{relative_root}/#{params[:resource]}/#{meeting_path}"
      options[:meeting_logout_url] = base_url
      options[:hook_url] = "#{base_url}/callback"
      options[:moderator_message] = t('moderator_default_message', url: "<a href=\"#{base_url}\" target=\"_blank\"><u>#{base_url}</u></a>")

      bbb_res = bbb_join_url(
        meeting_id,
        params[:name],
        options
      )

      # the user can join the meeting
      if user
        if bbb_res[:returncode] && current_user == user
          JoinMeetingJob.perform_later(user, params[:id], base_url)
          WaitingList.empty(options[:room_owner], options[:meeting_name])
      # user will be waiting for a moderator
        else
          NotifyUserWaitingJob.perform_later(user.encrypted_id, params[:id], params[:name])
        end
      end

      render_bbb_response bbb_res, bbb_res[:response]
    end
  end

  # POST /:resource/:room_id/:id/callback
  # Endpoint for webhook calls from BigBlueButton
  def callback
    # respond with 200 anyway so BigBlueButton knows the hook call was ok
    # but abort execution
    head(:ok) && return unless validate_checksum

    begin
      event = params['event']
      data = event.is_a?(String) ? JSON.parse(params['event']) : event
      treat_callback_event(data)
    rescue Exception => e
      logger.error "Error parsing webhook data. Data: #{data}, exception: #{e.inspect}"

      # respond with 200 anyway so BigBlueButton knows the hook call was ok
      head(:ok) && return
    end
  end

  # DELETE /rooms/:room_id/:id/end
  def end
    load_and_authorize_room_owner!

    bbb_res = bbb_end_meeting "#{@user.encrypted_id}-#{params[:id]}"
    if bbb_res[:returncode] || bbb_res[:status] == :not_found
      EndMeetingJob.perform_later(@user.encrypted_id, params[:id])
      bbb_res[:status] = :ok
    end
    render_bbb_response bbb_res
  end

  # GET /rooms/:room_id/recordings
  # GET /rooms/:room_id/:id/recordings
  def recordings
    load_room!

    # bbb_res = bbb_get_recordings "#{@user.encrypted_id}-#{params[:id]}"
    options = { "meta_room-id": @user.encrypted_id }
    if params[:id]
      options["meta_meeting-name"] = params[:id]
    end
    bbb_res = bbb_get_recordings(options)
    render_bbb_response bbb_res, bbb_res[:recordings]
  end

  # PATCH /rooms/:room_id/recordings/:record_id
  # PATCH /rooms/:room_id/:id/recordings/:record_id
  def update_recordings
    published = params[:published] == 'true'
    metadata = params.select{ |k, v| k.match(/^meta_/) }
    bbb_res = bbb_update_recordings(params[:record_id], published, metadata)
    if bbb_res[:returncode]
      RecordingUpdatesJob.perform_later(@user.encrypted_id, params[:record_id])
    end
    render_bbb_response bbb_res
  end

  # DELETE /rooms/:room_id/recordings/:record_id
  # DELETE /rooms/:room_id/:id/recordings/:record_id
  def delete_recordings
    recording = bbb_get_recordings({recordID: params[:record_id]})[:recordings].first
    bbb_res = bbb_delete_recordings(params[:record_id])
    if bbb_res[:returncode]
      RecordingDeletesJob.perform_later(@user.encrypted_id, params[:record_id], recording[:metadata][:"meeting-name"])
    end
    render_bbb_response bbb_res
  end

  # POST /rooms/:room_id/recordings/:record_id
  # POST /rooms/:room_id/:id/recordings/:record_id
  def youtube_publish
    # If we can't get the client, then they don't have a Youtube account.
    begin
      client = Yt::Account.new(access_token: current_user.token)
      video = client.upload_video(get_webcams_url(params[:record_id]),
              title: params[:video_title],
              description: t('youtube_description', url: 'https://bigbluebutton.org/'),
              privacy_status: params[:privacy_status])
    rescue => e
      errors = e.response_body['error']['errors']
      # Many complications, start by getting them to refresh their token.
      if errors.length > 1
        redirect_url = user_login_url
      else
        error = errors[0]
        if error['message'] == "Unauthorized"
          redirect_url = 'https://m.youtube.com/create_channel'
        else
          # In this case, they don't have a youtube channel connected to their account, so prompt to create one.
          redirect_url = user_login_url
        end
      end
    end
    render json: {:url => redirect_url}
  end

  # POST /rooms/:room_id/recordings/can_upload
  def can_upload
    # The recording is uploadable if it contains webcam data and they are logged in through Google.
    if Rails.configuration.enable_youtube_uploading == false then
      uploadable = 'uploading_disabled'
    elsif current_user.provider != 'google'
      uploadable = 'invalid_provider'
    else
      uploadable = (Faraday.head(get_webcams_url(params[:rec_id])).status == 200 && current_user.provider == 'google').to_s
    end
    render json: {:uploadable => uploadable}
  end

  def get_webcams_url(recording_id)
    uri = URI.parse(Rails.configuration.bigbluebutton_endpoint)
    uri.scheme + '://' + uri.host + '/presentation/' + recording_id + '/video/webcams.webm'
  end

  private

  def load_room!
    @user = User.find_by encrypted_id: params[:room_id]
    if !@user
      render head(:not_found) && return
    end
  end

  def load_and_authorize_room_owner!
    load_room!

    if !current_user || current_user != @user
      render head(:unauthorized) && return
    end
  end

  def authorize_recording_owner!
    load_and_authorize_room_owner!

    recordings = bbb_get_recordings({recordID: params[:record_id]})[:recordings]
    recordings.each do |recording|
      if recording[:recordID] == params[:record_id]
        return true
      end
    end
    render head(:not_found) && return
  end

  def render_bbb_response(bbb_res, response={})
    @messageKey = bbb_res[:messageKey]
    @message = bbb_res[:message]
    @status = bbb_res[:status]
    @response = response
    render status: @status
  end

  def read_body(request)
    request.body.read.force_encoding("UTF-8")
  end

  def treat_callback_event(event)
    # Check if the event is a BigBlueButton 2.0 event.
    if event.has_key?('envelope')
      eventName = (event.present? && event['envelope'].present?) ? event['envelope']['name'] : nil
    else # The event came from BigBlueButton 1.1 (or earlier).
      eventName = (event.present? && event['header'].present?) ? event['header']['name'] : nil
    end

    # a recording is ready
    if eventName == "publish_ended"
      if event['payload'] && event['payload']['metadata'] && event['payload']['meeting_id']
        token = event['payload']['metadata'][META_TOKEN]
        room_id = event['payload']['metadata']['room-id']
        record_id = event['payload']['meeting_id']
        duration_data = event['payload']['duration']

        # the webhook event doesn't have all the data we need, so we need
        # to send a getRecordings anyway
        # TODO: if the webhooks included all data in the event we wouldn't need this
        rec_info = bbb_get_recordings({recordID: record_id})
        rec_info = rec_info[:recordings].first
        RecordingCreatedJob.perform_later(token, room_id, parse_recording_for_view(rec_info))

        rec_info[:duration] = duration_data.to_json

        # send an email to the owner of this recording, if defined
        if Rails.configuration.mail_notifications
          owner = User.find_by(encrypted_id: room_id)
          RecordingReadyEmailJob.perform_later(owner, parse_recording_for_view(rec_info)) if owner.present?
        end
      else
        logger.error "Bad format for event #{event}, won't process"
      end
    elsif eventName == "meeting_created_message" || eventName == "MeetingCreatedEvtMsg" 
      # Fire an Actioncable event that updates _previously_joined for the client.
      actioncable_event('create')
    elsif eventName == "meeting_destroyed_event" || eventName == "MeetingEndedEvtMsg"
      actioncable_event('destroy')

      # Since the meeting is destroyed we have no way get the callback url to remove the meeting, so we must build it.
      remove_url = build_callback_url(params[:id], params[:room_id])

      # Remove webhook for the meeting.
      webhook_remove(remove_url)
    elsif eventName == "user_joined_message"
      actioncable_event('join', {user_id: event['payload']['user']['extern_userid'], user: event['payload']['user']['name'], role: event['payload']['user']['role']})
    elsif eventName == "UserJoinedMeetingEvtMsg"
      actioncable_event('join', {user_id: event['core']['body']['intId'], user: event['core']['body']['name'], role: event['core']['body']['role']})
    elsif eventName == "user_left_message"
      actioncable_event('leave', {user_id: event['payload']['user']['extern_userid']})
    elsif eventName == "UserLeftMeetingEvtMsg"
      actioncable_event('leave', {user_id: event['core']['body']['intId']})
    else
      logger.info "Callback event will not be treated. Event name: #{eventName}"
    end

    render head(:ok) && return
  end

  def build_callback_url(id, room_id)
    "#{request.base_url}#{relative_root}/rooms/#{room_id}/#{URI.encode(id)}/callback"
  end

  def actioncable_event(method, data = {})
    data = {method: method, meeting: params[:id], room: params[:room_id]}.merge(data)
    ActionCable.server.broadcast('refresh_meetings', data)
  end

  # Validates the checksum received in a callback call.
  # If the checksum doesn't match, renders an ok and aborts execution.
  def validate_checksum
    secret = ENV['BIGBLUEBUTTON_SECRET']
    checksum = params["checksum"]
    return false unless checksum

    # Message is only encoded if it comes from the bbb-webhooks node application.
    # The post process script does not encode it's response body.
    begin
      # Decode and break the body into parts.
      parts = URI.decode_www_form(read_body(request))

      # Convert the data into the correct checksum format, replace ruby hash arrows.
      converted_data = {parts[0][0]=>parts[0][1],parts[1][0]=>parts[1][1].to_i}.to_s.gsub!('=>', ':')

      # Manually remove the space between the two elements.
      converted_data[converted_data.rindex("timestamp") - 2] = ''
      callback_url = uri_remove_param(request.original_url, "checksum")
      checksum_str = "#{callback_url}#{converted_data}#{secret}"
    rescue
      # Data was not recieved encoded (sent from post process script).
      data = read_body(request)
      callback_url = uri_remove_param(request.original_url, "checksum")
      checksum_str = "#{callback_url}#{data}#{secret}"
    end

    calculated_checksum = Digest::SHA1.hexdigest(checksum_str)

    if calculated_checksum != checksum
      logger.error "Checksum did not match. Calculated: #{calculated_checksum}, received: #{checksum}"
      false
    else
      true
    end
  end

  # Removes parameters from an URI
  def uri_remove_param(uri, params = nil)
    return uri unless params
    params = Array(params)
    uri_parsed = URI.parse(uri)
    return uri unless uri_parsed.query
    new_params = uri_parsed.query.gsub(/&amp;/, '&').split('&').reject { |q| params.include?(q.split('=').first) }
    uri = uri.split('?').first
    if new_params.count > 0
      "#{uri}?#{new_params.join('&')}"
    else
      uri
    end
  end
end
