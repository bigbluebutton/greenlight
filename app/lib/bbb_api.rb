module BbbApi
  def bbb_endpoint
    Rails.application.secrets[:bbb_endpoint]
  end

  def bbb_secret
    Rails.application.secrets[:bbb_secret]
  end

  def bbb
    @bbb ||= BigBlueButton::BigBlueButtonApi.new(bbb_endpoint + "api", bbb_secret, "0.8", true)
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

    if !bbb
      return call_invalid_res
    else
      meeting_id = (Digest::SHA1.hexdigest(Rails.application.secrets[:secret_key_base]+meeting_token)).to_s

      # See if the meeting is running
      begin
        bbb_meeting_info = bbb.get_meeting_info( meeting_id, nil )
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
        meeting_options = {record: options[:meeting_recorded].to_s, logoutURL: logout_url, moderatorPW: moderator_password, attendeePW: viewer_password}
        # Create the meeting
        bbb.create_meeting(meeting_token, meeting_id, meeting_options)

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
      return success_res(join_url)
    end
  end

  def bbb_get_recordings(meeting_id, record_id=nil)
    options={}
    if record_id
      options[:recordID] = record_id
    end
    if meeting_id
      options[:meetingID] = (Digest::SHA1.hexdigest(Rails.application.secrets[:secret_key_base]+meeting_id)).to_s
    end
    bbb_safe_execute :get_recordings, options
  end

  def bbb_update_recordings(id, published)
    bbb_safe_execute :publish_recordings, id, published
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

  def success_res(join_url)
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
    {
      returncode: false,
      messageKey: 'BBB'+exc.key.capitalize.underscore,
      message: exc.message,
      status: :internal_server_error
    }
  end
end
