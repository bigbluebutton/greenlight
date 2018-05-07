class Meeting < ApplicationRecord

  before_create :generate_meeting_id

  belongs_to :room

  # Creates a meeting on the BigBlueButton server.
  def create(options = {})
    create_options = {
      record: options[:meeting_recorded].to_s,
      logoutURL: options[:meeting_logout_url] || '',
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
      bbb.create_meeting(name, uid, create_options)
    rescue BigBlueButton::BigBlueButtonException => exc
      puts "BigBlueButton failed on create: #{exc.key}: #{exc.message}"
    end
  end

  # Returns a URL to join a user into a meeting.
  def join_path(username, options = {})
    # Create the meeting if it isn't running.
    create(options) unless is_running?

    # Set meeting options.
    options[:meeting_logout_url] ||= nil
    options[:moderator_message] ||= ''
    options[:user_is_moderator] ||= false

    options[:meeting_recorded] ||= false

    #options[:wait_for_moderator] ||= false
    #options[:meeting_name] ||= name
    #options[:room_owner] ||= nil

    return call_invalid_res if !bbb

    # Get the meeting info.
    meeting_info = bbb.get_meeting_info(uid, nil) 

    # Determine the password to use when joining.
    password = if options[:user_is_moderator]
      meeting_info[:moderatorPW]
    else
      meeting_info[:attendeePW]
    end

    # Generate the join URL.
    bbb.join_meeting_url(uid, username, password)
  end

  # Checks if a meeting is running on the BigBlueButton server.
  def is_running?
    begin
      bbb.get_meeting_info(uid, nil)
      return true
    rescue BigBlueButton::BigBlueButtonException => exc
      return false
    end
  end

  private

  def bbb_endpoint
    Rails.configuration.bigbluebutton_endpoint
  end

  def bbb_secret
    Rails.configuration.bigbluebutton_secret
  end

  # Use one common instance of the BigBlueButton API for all meetings.
  def bbb
    @@bbb ||= BigBlueButton::BigBlueButtonApi.new(bbb_endpoint + "api", bbb_secret, "0.8")
  end

  # Generates a BigBlueButton meeting id from a meeting token.
  def generate_meeting_id
    self.uid = Digest::SHA1.hexdigest(Rails.application.secrets[:secret_key_base] + name + Time.now.to_i.to_s).to_s
  end

  # Generates a random password for a meeting.
  def random_password(length)
    o = ([('a'..'z'), ('A'..'Z')].map do |i| i.to_a end).flatten
    ((0...length).map do o[rand(o.length)] end).join
  end
end