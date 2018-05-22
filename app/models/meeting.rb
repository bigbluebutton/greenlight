class Meeting < ApplicationRecord

  before_create :generate_meeting_id

  validates :name, presence: true

  belongs_to :room, optional: true

  RETURNCODE_SUCCESS = "SUCCESS"

  # Creates a meeting on the BigBlueButton server.
  def start_meeting(options = {})
    create_options = {
      record: options[:meeting_recorded].to_s,
      logoutURL: options[:meeting_logout_url] || '',
      moderatorPW: random_password(12),
      attendeePW: random_password(12),
      moderatorOnlyMessage: options[:moderator_message]
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
    start_meeting(options) unless is_running?

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

  # Fetches all recordings for a meeting.
  def recordings
    res = bbb.get_recordings(meetingID: uid)
    res[:recordings]
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

  # Sets a BigBlueButtonApi object for interacting with the API.
  def bbb
    @bbb ||= if Rails.configuration.loadbalanced_configuration
      lb_user = retrieve_loadbalanced_credentials(self.room.user.provider)
      BigBlueButton::BigBlueButtonApi.new(remove_slash(lb_user["apiURL"]), lb_user["secret"], "0.8")
    else
      BigBlueButton::BigBlueButtonApi.new(remove_slash(bbb_endpoint), bbb_secret, "0.8")
    end
  end

  # Rereives the loadbalanced BigBlueButton credentials for a user.
  def retrieve_loadbalanced_credentials(provider)
    # Include Omniauth accounts under the Greenlight provider.
    provider = "greenlight" if Rails.configuration.providers.include?(provider.to_sym)

    # Build the URI.
    uri = encode_bbb_url(
      Rails.configuration.loadbalancer_endpoint,
      Rails.configuration.loadbalancer_secret,
      {name: provider}
    )

    # Make the request.
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    response = http.get(uri.request_uri)

    unless response.kind_of?(Net::HTTPSuccess)
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
