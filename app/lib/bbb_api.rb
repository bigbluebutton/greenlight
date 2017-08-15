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

module BbbApi
  META_LISTED = "gl-listed"
  META_TOKEN = "gl-token"
  META_HOOK_URL = "gl-webhooks-callback-url"

  def bbb_endpoint
    Rails.configuration.bigbluebutton_endpoint
  end

  def bbb_secret
    Rails.configuration.bigbluebutton_secret
  end

  def bbb
    @bbb ||= BigBlueButton::BigBlueButtonApi.new(bbb_endpoint + "api", bbb_secret, "0.8")
  end

  def bbb_meeting_id(id)
    Digest::SHA1.hexdigest(Rails.application.secrets[:secret_key_base]+id).to_s
  end

  def random_password(length)
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    password = (0...length).map { o[rand(o.length)] }.join
    return password
  end

  def bbb_join_url(meeting_token, full_name, options={})
    options[:meeting_recorded] ||= false
    options[:user_is_moderator] ||= false
    options[:wait_for_moderator] ||= false
    options[:meeting_logout_url] ||= nil
    options[:meeting_name] ||= meeting_token
    options[:room_owner] ||= nil
    options[:moderator_message] ||= ''

    if !bbb
      return call_invalid_res
    else
      meeting_id = bbb_meeting_id(meeting_token)

      # See if the meeting is running
      begin
        bbb_meeting_info = bbb.get_meeting_info(meeting_id, nil)
      rescue BigBlueButton::BigBlueButtonException => exc
        # This means that is not created

        if options[:wait_for_moderator] && !options[:user_is_moderator]
          return wait_moderator_res
        end

        logger.info "Message for the log file #{exc.key}: #{exc.message}"

        # Prepare parameters for create
        logout_url = options[:meeting_logout_url] || "#{request.base_url}"
        moderator_password = random_password(12)
        viewer_password = random_password(12)
        meeting_options = {
          record: options[:meeting_recorded].to_s,
          logoutURL: logout_url,
          moderatorPW: moderator_password,
          attendeePW: viewer_password,
          moderatorOnlyMessage: options[:moderator_message],
          "meta_#{BbbApi::META_LISTED}": false,
          "meta_#{BbbApi::META_TOKEN}": meeting_token
        }
        meeting_options.merge!(
          { "meta_#{BbbApi::META_HOOK_URL}": options[:hook_url] }
        ) if options[:hook_url]

        # these parameters are used to filter recordings by room and meeting
        meeting_options.merge!(
          { "meta_room-id": options[:room_owner],
            "meta_meeting-name": options[:meeting_name]}
        ) if options[:room_owner]

        # Only register webhooks if they are enabled it's not a guest meeting.
        if Rails.configuration.use_webhooks && params[:resource] == 'rooms'
          webhook_register(options[:hook_url], meeting_id)
        end

        # Create the meeting
        begin
          bbb.create_meeting(options[:meeting_name], meeting_id, meeting_options)
        rescue BigBlueButton::BigBlueButtonException => exc
          logger.info "BBB error on create #{exc.key}: #{exc.message}"
        end

        # And then get meeting info
        bbb_meeting_info = bbb.get_meeting_info( meeting_id, nil )
      end

      if options[:wait_for_moderator] && !options[:user_is_moderator] && bbb_meeting_info[:moderatorCount] <= 0
        return wait_moderator_res
      end

      # Get the join url
      if (options[:user_is_moderator])
        password = bbb_meeting_info[:moderatorPW]
      else
        password = bbb_meeting_info[:attendeePW]
      end
      join_url = bbb.join_meeting_url(meeting_id, full_name, password )
      return success_join_res(join_url)
    end
  end

  def bbb_get_meeting_info(id)
    meeting_id = bbb_meeting_id(id)
    response_data = bbb.get_meeting_info(meeting_id, nil)
  rescue BigBlueButton::BigBlueButtonException => exc
    response_data = bbb_exception_res exc
  end

  def bbb_get_recordings(options={})
    if options[:meetingID]
      options[:meetingID] = bbb_meeting_id(options[:meetingID])
    end
    res = bbb_safe_execute :get_recordings, options

    # ensure recordings is an array
    if !res[:recordings]
      res[:recordings] = []
    elsif !res[:recordings].is_a? Array
      res[:recordings] = [res[:recordings]]
    end

    res[:recordings].each do |recording|
      next if recording.key?(:error)
      pref_preview = {}
      recording[:length] = recording[:playback][:format].is_a?(Hash) ? recording[:playback][:format][:length] : recording[:playback][:format].first[:length]
      # create a playbacks attribute on recording for playback formats
      recording[:playbacks] = if !recording[:playback] || !recording[:playback][:format]
        []
      elsif recording[:playback][:format].is_a? Array
        recording[:playback][:format]
      else
        [recording[:playback][:format]]
      end

      recording[:playbacks].each_with_index do |playback, index|
        # create a previews attribute on playbacks for preview images
        playback[:previews] = if !playback[:preview] || !playback[:preview][:images] || !playback[:preview][:images][:image]
          []
        elsif playback[:preview][:images][:image].is_a? Array
          playback[:preview][:images][:image]
        else
          [playback[:preview][:images][:image]]
        end
        if playback[:type] == 'presentation' && playback[:previews].present?
          pref_preview[:presentation] = index
        elsif playback[:previews].present? && pref_preview[:other].blank?
          pref_preview[:other] = index
        end
      end

      # create a previews attribute on recordings for preview images
      recording[:previews] = if pref_preview[:presentation]
        recording[:playbacks][pref_preview[:presentation]][:previews]
      elsif pref_preview[:other]
        recording[:playbacks][pref_preview[:other]][:previews]
      else
        []
      end

      recording[:listed] = bbb_is_recording_listed(recording)
    end
    res
  end

  def bbb_end_meeting(id)
    # get meeting info for moderator password
    meeting_id = bbb_meeting_id(id)
    bbb_meeting_info = bbb.get_meeting_info(meeting_id, nil)

    response_data = if bbb_meeting_info.is_a?(Hash) && bbb_meeting_info[:moderatorPW]
      bbb.end_meeting(meeting_id, bbb_meeting_info[:moderatorPW])
    else
      {}
    end
    response_data[:status] = :ok
    response_data
  rescue BigBlueButton::BigBlueButtonException => exc
    response_data = bbb_exception_res exc
  end

  def bbb_update_recordings(id, published, metadata)
    bbb_safe_execute :publish_recordings, id, published

    params = { recordID: id }.merge(metadata)
    bbb_safe_execute :send_api_request, "updateRecordings", params
  end

  def bbb_delete_recordings(id)
    bbb_safe_execute :delete_recordings, id
  end

  # method must be a symbol of the method's name
  def bbb_safe_execute(method, *args)
    if !bbb
      return call_invalid_res
    else
      begin
        response_data = bbb.send(method, *args)
        response_data[:status] = :ok
      rescue BigBlueButton::BigBlueButtonException => exc
        response_data = bbb_exception_res exc
      end
    end
    response_data
  end

  def bbb_is_recording_listed(recording)
    !recording[:metadata].blank? &&
      recording[:metadata][BbbApi::META_LISTED.to_sym] == "true"
  end

  # Parses a recording as returned by getRecordings and returns it
  # as an object as expected by the views.
  # TODO: this is almost the same done by jbuilder templates (bbb/recordings),
  #       how to reuse them?
  def parse_recording_for_view(recording)
    recording[:previews] ||= []
    previews = recording[:previews].map do |preview|
      {
        url: preview[:content],
        width: preview[:width],
        height: preview[:height],
        alt: preview[:alt]
      }
    end
    recording[:playbacks] ||= []
    playbacks = recording[:playbacks].map do |playback|
      {
        type: playback[:type],
        type_i18n: t(playback[:type]),
        url: playback[:url],
        previews: previews
      }
    end
    {
      id: recording[:recordID],
      name: recording[:name],
      published: recording[:published],
      end_time: recording[:endTime].to_s,
      start_time: recording[:startTime].to_s,
      length: recording[:length],
      listed: recording[:listed],
      playbacks: playbacks,
      previews: previews,
      participants: recording[:participants],
      duration: recording[:duration]
    }
  end

  def webhook_register(url, meeting_id=nil)
    params = { callbackURL: url }
    params.merge!({ meetingID: meeting_id }) if meeting_id.present?
    bbb_safe_execute :send_api_request, "hooks/create", params
  end

  def webhook_remove(url)
    res = bbb_safe_execute :send_api_request, "hooks/list"
    if res && res[:hooks] && res[:hooks][:hook]
      res[:hooks][:hook] = [res[:hooks][:hook]] unless res[:hooks][:hook].is_a?(Array)
      hook = res[:hooks][:hook].select{ |h|
        h[:callbackURL] == url
      }.first
      if hook.present?
        params = { hookID: hook[:hookID] }
        bbb_safe_execute :send_api_request, "hooks/destroy", params
      end
    end
  end

  def success_join_res(join_url)
    {
      returncode: true,
      messageKey: "ok",
      message: "Execute the redirect",
      status: :ok,
      response: {
        join_url: join_url
      }
    }
  end

  def wait_moderator_res
    {
      returncode: false,
      messageKey: "wait_for_moderator",
      message: "Waiting for moderator",
      status: :ok
    }
  end

  def call_invalid_res
    {
      returncode: false,
      messageKey: "BBB_API_call_invalid",
      message: "BBB API call invalid.",
      status: :internal_server_error
    }
  end

  def bbb_exception_res(exc)
    res = {
      returncode: false,
      messageKey: 'BBB'+exc.key.capitalize.underscore,
      message: exc.message,
      status: :unprocessable_entity
    }
    if res[:messageKey] == 'BBBnotfound'
      res[:status] = :not_found
    end
    res
  rescue
    {
      returncode: false,
      status: :internal_server_error
    }
  end
end
