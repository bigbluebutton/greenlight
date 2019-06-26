# frozen_string_literal: true

module BbbApi
  RETURNCODE_SUCCESS = "SUCCESS"

  def bbb_endpoint
    Rails.configuration.bigbluebutton_endpoint
  end

  def bbb_secret
    Rails.configuration.bigbluebutton_secret
  end

  # Sets a BigBlueButtonApi object for interacting with the API.
  def bbb
    if Rails.configuration.loadbalanced_configuration
      if instance_of? Room
        # currently in the Room Model
        user_domain = retrieve_provider_info(owner.provider)
      elsif instance_of? User
        # currently in the User Model
        user_domain = retrieve_provider_info(provider)
      end

      BigBlueButton::BigBlueButtonApi.new(remove_slash(user_domain["apiURL"]), user_domain["secret"], "0.8")
    else
      BigBlueButton::BigBlueButtonApi.new(remove_slash(bbb_endpoint), bbb_secret, "0.8")
    end
  end

  # Rereives info from the loadbalanced in regards to a Provider (or tenant).
  def retrieve_provider_info(provider, api = 'api', route = 'getUser')
    # Include Omniauth accounts under the Greenlight provider.
    raise "Provider not included." if !provider || provider.empty?

    # Build the URI.
    uri = encode_bbb_url(
      Rails.configuration.loadbalancer_endpoint + api + '/',
      Rails.configuration.loadbalancer_secret,
      { name: provider },
      route
    )

    logger.info uri

    # Make the request.
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    response = http.get(uri.request_uri)

    # Parse XML.
    doc = XmlSimple.xml_in(response.body, 'ForceArray' => false)

    raise doc['message'] unless response.is_a?(Net::HTTPSuccess)

    # Return the user credentials if the request succeeded on the loadbalancer.
    return doc['user'] if doc['returncode'] == 'SUCCESS'

    raise "User with provider #{provider} does not exist." if doc['messageKey'] == 'noSuchUser'
    raise "API call #{url} failed with #{doc['messageKey']}."
  end

  # Builds a request to retrieve credentials from the load balancer.
  def encode_bbb_url(base_url, secret, params, route = 'getUser')
    encoded_params = params.to_param
    string = route + encoded_params + secret
    checksum = OpenSSL::Digest.digest('sha1', string).unpack1('H*')

    URI.parse("#{base_url}#{route}?#{encoded_params}&checksum=#{checksum}")
  end

  # Removes trailing forward slash from a URL.
  def remove_slash(s)
    s.nil? ? nil : s.chomp("/")
  end
end
