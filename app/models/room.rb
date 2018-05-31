class Room < ApplicationRecord

  before_create :setup

  validates :name, presence: true

  belongs_to :user
  has_one :meeting

  ROOM_ICONS = %w(circle star certificate play cloud heart square bookmark cog)
  RETURNCODE_SUCCESS = "SUCCESS"

  def to_param
    uid  
  end

  # Determines if a user owns a room.
  def owned_by?(user)
    return false if user.nil?
    user.rooms.include?(self)
  end

  # Checks if a room is running on the BigBlueButton server.
  def is_running?
    begin
      bbb.get_meeting_info(bbb_id, nil)
      return true
    rescue BigBlueButton::BigBlueButtonException => exc
      return false
    end
  end

  # Determines the invite URL for the room.
  def invite_path
    "/r/#{uid}"
  end

  # Creates a meeting on the BigBlueButton server.
  def start_session(options = {})
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
      bbb.create_meeting(name, bbb_id, create_options)
    rescue BigBlueButton::BigBlueButtonException => exc
      puts "BigBlueButton failed on create: #{exc.key}: #{exc.message}"
    end
  end

  # Returns a URL to join a user into a meeting.
  def join_path(user, options = {})
    user = user.name if user.is_a?(User)

    # Create the meeting if it isn't running.
    start_session(options) unless is_running?

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
    meeting_info = bbb.get_meeting_info(bbb_id, nil) 

    # Determine the password to use when joining.
    password = if options[:user_is_moderator]
      meeting_info[:moderatorPW]
    else
      meeting_info[:attendeePW]
    end

    # Generate the join URL.
    bbb.join_meeting_url(bbb_id, user, password)
  end

  # Fetches all recordings for a meeting.
  def recordings
    res = bbb.get_recordings(meetingID: bbb_id)
    res[:recordings]
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
    @bbb = BigBlueButton::BigBlueButtonApi.new(remove_slash(bbb_endpoint), bbb_secret, "0.8")
    #@bbb ||= if Rails.configuration.loadbalanced_configuration
    #  lb_user = retrieve_loadbalanced_credentials(self.room.user.provider)
    #  BigBlueButton::BigBlueButtonApi.new(remove_slash(lb_user["apiURL"]), lb_user["secret"], "0.8")
    #else
    #  BigBlueButton::BigBlueButtonApi.new(remove_slash(bbb_endpoint), bbb_secret, "0.8")
    #end
  end

  # Generates a uid for the room and BigBlueButton.
  def setup
    self.uid = [user.firstname, (0...8).map { (65 + rand(26)).chr }.join].join('-').downcase
    self.bbb_id = Digest::SHA1.hexdigest(Rails.application.secrets[:secret_key_base] + Time.now.to_i.to_s).to_s

    self.icon = ROOM_ICONS.sample
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

  # Generates a random password for a meeting.
  def random_password(length)
    o = ([('a'..'z'), ('A'..'Z')].map do |i| i.to_a end).flatten
    ((0...length).map do o[rand(o.length)] end).join
  end
end
