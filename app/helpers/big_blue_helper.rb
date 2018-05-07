module BigBlueHelper

  META_LISTED = "gl-listed"
  META_TOKEN = "gl-token"

  def bbb_endpoint
    Rails.configuration.bigbluebutton_endpoint
  end

  def bbb_secret
    Rails.configuration.bigbluebutton_secret
  end

  def bbb
    @bbb ||= BigBlueButton::BigBlueButtonApi.new(bbb_endpoint + "api", bbb_secret, "0.8")
  end
  
  # Generates a BigBlueButton meeting id from a meeting token.
  def bbb_meeting_id(id)
    Digest::SHA1.hexdigest(Rails.application.secrets[:secret_key_base] + id).to_s
  end

  # Generates a random password for a meeting.
  def random_password(length)
    o = ([('a'..'z'), ('A'..'Z')].map do |i| i.to_a end).flatten
    ((0...length).map do o[rand(o.length)] end).join
  end

  # Checks if a meeting is running on the BigBlueButton server.
  def meeting_is_running?(id)
    begin
      bbb.get_meeting_info(id, nil)
      return true
    rescue BigBlueButton::BigBlueButtonException => exc
      return false
    end
  end

  def start_meeting(options)
    meeting_id = bbb_meeting_id(name)

    # Need to create the meeting on the BigBlueButton server.
    create_options = {
      record: options[:meeting_recorded].to_s,
      #logoutURL: options[:meeting_logout_url] || request.base_url,
      moderatorPW: random_password(12),
      attendeePW: random_password(12),
      moderatorOnlyMessage: options[:moderator_message],
      "meta_#{BigBlueHelper::META_LISTED}": false,
      "meta_#{BigBlueHelper::META_TOKEN}": name
    }

    #meeting_options.merge!(
      #{ "meta_room-id": options[:room_owner],
      #  "meta_meeting-name": options[:meeting_name]}
    #) if options[:room_owner]

    # Send the create request.
    begin
      bbb.create_meeting(name, meeting_id, create_options)
    rescue BigBlueButton::BigBlueButtonException => exc
      puts "BigBlueButton failed on create: #{exc.key}: #{exc.message}"
    end

    # Get the meeting info.
    #bbb_meeting_info = bbb.get_meeting_info(meeting_id, nil)

    meeting_id
  end

  # Generates a URL to join a BigBlueButton session.
  def join_url(meeting_id, username, options = {})
    options[:meeting_recorded] ||= false
    options[:user_is_moderator] ||= false
    options[:wait_for_moderator] ||= false
    options[:meeting_logout_url] ||= nil
    options[:meeting_name] ||= name
    options[:room_owner] ||= nil
    options[:moderator_message] ||= ''

    return call_invalid_res if !bbb

    # Get the meeting info.
    meeting_info = bbb.get_meeting_info(meeting_id, nil) 

    # Determine the password to use when joining.
    password = if options[:user_is_moderator]
      meeting_info[:moderatorPW]
    else
      meeting_info[:attendeePW]
    end

    # Generate the join URL.
    bbb.join_meeting_url(meeting_id, username, password)
  end

  # Generates a URL to join a BigBlueButton session.
  def join_url_old(meeting_token, full_name, options={})
    options[:meeting_recorded] ||= false
    options[:user_is_moderator] ||= false
    options[:wait_for_moderator] ||= false
    options[:meeting_logout_url] ||= nil
    options[:meeting_name] ||= meeting_token
    options[:room_owner] ||= nil
    options[:moderator_message] ||= ''

    return call_invalid_res if !bbb

    meeting_id = bbb_meeting_id(meeting_token)

    unless meeting_is_running?(meeting_id)
      # Need to create the meeting on the BigBlueButton server.
      create_options = {
        record: options[:meeting_recorded].to_s,
        logoutURL: options[:meeting_logout_url] || request.base_url,
        moderatorPW: random_password(12),
        attendeePW: random_password(12),
        moderatorOnlyMessage: options[:moderator_message],
        "meta_#{BigBlueHelper::META_LISTED}": false,
        "meta_#{BigBlueHelper::META_TOKEN}": meeting_token
      }

      #meeting_options.merge!(
        #{ "meta_room-id": options[:room_owner],
        #  "meta_meeting-name": options[:meeting_name]}
      #) if options[:room_owner]

      # Send the create request.
      begin
        bbb.create_meeting(options[:meeting_name], meeting_id, create_options)
      rescue BigBlueButton::BigBlueButtonException => exc
        puts "BigBlueButton failed on create: #{exc.key}: #{exc.message}"
      end

      # Get the meeting info.
      bbb_meeting_info = bbb.get_meeting_info(meeting_id, nil) 
    end

    # Determine the password to use when joining.
    password = if options[:user_is_moderator]
      bbb_meeting_info[:moderatorPW]
    else
      bbb_meeting_info[:attendeePW]
    end

    # Generate the join URL.
    bbb.join_meeting_url(meeting_id, full_name, password)
  end
end