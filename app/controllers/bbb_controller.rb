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
  before_action :validate_checksum, only: :callback

  # GET /:resource/:id/join
  def join
    if params[:name].blank?
      render_bbb_response("missing_parameter", "user name was not included", :unprocessable_entity)
    else
      user = User.find_by encrypted_id: params[:id]

      options = if user
        {
          wait_for_moderator: true,
          meeting_recorded: true,
          meeting_name: user.name,
          user_is_moderator: current_user == user
        }
      else
        {
          user_is_moderator: true
        }
      end
      base_url = "#{request.base_url}/#{params[:resource]}/#{params[:id]}"
      options[:meeting_logout_url] = base_url
      options[:hook_url] = "#{base_url}/callback"

      bbb_res = bbb_join_url(
        params[:id],
        params[:name],
        options
      )

      # the user can join the meeting
      if bbb_res[:returncode] && current_user && current_user == user
        JoinMeetingJob.perform_later(params[:id])

      # user will be waiting for a moderator
      else
        NotifyUserWaitingJob.perform_later(params[:id], params[:name])
      end

      render_bbb_response bbb_res, bbb_res[:response]
    end
  end

  # POST /:resource/:id/callback
  # Endpoint for webhook calls from BigBlueButton
  def callback
    begin
      data = JSON.parse(read_body(request))
      treat_callback_event(data["event"])
    rescue Exception => e
      logger.error "Error parsing webhook data. Data: #{data}, exception: #{e.inspect}"

      # respond with 200 anyway so BigBlueButton knows the hook call was ok
      render head(:ok)
    end
  end

  # DELETE /rooms/:id/end
  def end
    load_and_authorize_room_owner!

    bbb_res = bbb_end_meeting @user.encrypted_id
    if bbb_res[:returncode]
      EndMeetingJob.perform_later(@user.encrypted_id)
    end
    render_bbb_response bbb_res
  end

  # GET /rooms/:id/recordings
  def recordings
    load_room!

    bbb_res = bbb_get_recordings @user.encrypted_id
    render_bbb_response bbb_res, bbb_res[:recordings]
  end

  # PATCH /rooms/:id/recordings/:record_id
  def update_recordings
    published = params[:published] == 'true'
    metadata = params.select{ |k, v| k.match(/^meta_/) }
    bbb_res = bbb_update_recordings(params[:record_id], published, metadata)
    if bbb_res[:returncode]
      RecordingUpdatesJob.perform_later(@user.encrypted_id, params[:record_id])
    end
    render_bbb_response bbb_res
  end

  # DELETE /rooms/:id/recordings/:record_id
  def delete_recordings
    bbb_res = bbb_delete_recordings(params[:record_id])
    if bbb_res[:returncode]
      RecordingDeletesJob.perform_later(@user.encrypted_id, params[:record_id])
    end
    render_bbb_response bbb_res
  end

  private

  def load_room!
    @user = User.find_by encrypted_id: params[:id]
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

    recordings = bbb_get_recordings(params[:id])[:recordings]
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
    eventName = (event.present? && event['header'].present?) ? event['header']['name'] : nil

    # a recording is ready
    if eventName == "publish_ended"
      if event['payload'] && event['payload']['metadata'] && event['payload']['meeting_id']
        token = event['payload']['metadata'][META_TOKEN]
        record_id = event['payload']['meeting_id']

        # the webhook event doesn't have all the data we need, so we need
        # to send a getRecordings anyway
        # TODO: if the webhooks included all data in the event we wouldn't need this
        rec_info = bbb_get_recordings(token, record_id)
        rec_info = rec_info[:recordings].first
        RecordingCreatedJob.perform_later(token, parse_recording_for_view(rec_info))

        # send an email to the owner of this recording, if defined
        if Rails.configuration.mail_notifications
          owner = User.find_by(encrypted_id: token)
          RecordingReadyEmailJob.perform_later(owner) if owner.present?
        end

        # TODO: remove the webhook now that the meeting and recording are done
        # remove only if the meeting is not running, otherwise the hook is needed
        # if Rails.configuration.use_webhooks
        #   webhook_remove("#{base_url}/callback")
        # end
      else
        logger.error "Bad format for event #{event}, won't process"
      end
    else
      logger.info "Callback event will not be treated. Event name: #{eventName}"
    end

    render head(:ok) && return
  end

  # Validates the checksum received in a callback call.
  # If the checksum doesn't match, renders an ok and aborts execution.
  def validate_checksum
    secret = ENV['BIGBLUEBUTTON_SECRET']
    checksum = params["checksum"]
    data = read_body(request)
    callback_url = uri_remove_param(request.url, "checksum")

    checksum_str = "#{callback_url}#{data}#{secret}"
    calculated_checksum = Digest::SHA1.hexdigest(checksum_str)

    if calculated_checksum != checksum
      logger.error "Checksum did not match. Calculated: #{calculated_checksum}, received: #{checksum}"

      # respond with 200 anyway so BigBlueButton knows the hook call was ok
      # but abort execution
      render head(:ok) && return
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
