module BbbHelper
  def bbb_join_url(meeting_token, meeting_recorded=false, user_fullname='User', user_is_moderator=false)
    bbb ||= BigBlueButton::BigBlueButtonApi.new(helpers.bbb_endpoint + "api", bbb_secret, "0.8", true)
    if !bbb
      return { :returncode => false, :messageKey => "BBBAPICallInvalid", :message => "BBB API call invalid." }
    else
      meeting_id = (Digest::SHA1.hexdigest(Rails.application.secrets[:secret_key_base]+meeting_token)).to_s

      # See if the meeting is running
      begin
        bbb_meeting_info = bbb.get_meeting_info( meeting_id, nil )
      rescue BigBlueButton::BigBlueButtonException => exc
        # This means that is not created
        logger.info "Message for the log file #{exc.key}: #{exc.message}"

        # Prepare parameters for create
        logout_url = "#{request.base_url}/meeting/#{meeting_token}"
        moderator_password = random_password(12)
        viewer_password = random_password(12)
        meeting_options = {:record => meeting_recorded.to_s, :logoutURL => logout_url, :moderatorPW => moderator_password, :attendeePW => viewer_password }

        # Create the meeting
        bbb.create_meeting(meeting_token, meeting_id, meeting_options)

        # And then get meeting info
        bbb_meeting_info = bbb.get_meeting_info( meeting_id, nil )
      end

      # Get the join url
      if (user_is_moderator)
        password = bbb_meeting_info[:moderatorPW]
      else
        password = bbb_meeting_info[:attendeePW]
      end
      join_url = bbb.join_meeting_url(meeting_id, user_fullname, password )
      return { :returncode => true, :join_url => join_url, :messageKey => "", :message => "" }
    end
  end
end
