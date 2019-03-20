# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
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

module APIConcern
  extend ActiveSupport::Concern

  RETURNCODE_SUCCESS = "SUCCESS"

  def bbb_endpoint
    Rails.configuration.bigbluebutton_endpoint
  end

  def bbb_secret
    Rails.configuration.bigbluebutton_secret
  end

  # Sets a BigBlueButtonApi object for interacting with the API.
  def bbb
    @bbb ||= if Rails.configuration.loadbalanced_configuration
      lb_user = retrieve_loadbalanced_credentials(owner.provider)
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
      Rails.configuration.loadbalancer_endpoint + "getUser",
      Rails.configuration.loadbalancer_secret,
      name: provider
    )

    # Make the request.
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    response = http.get(uri.request_uri)

    unless response.is_a?(Net::HTTPSuccess)
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

  # Format recordings to match their current use in the app
  def format_recordings(api_res)
    api_res[:recordings].each do |r|
      next if r.key?(:error)
      # Format playbacks in a more pleasant way.
      r[:playbacks] = if !r[:playback] || !r[:playback][:format]
        []
      elsif r[:playback][:format].is_a?(Array)
        r[:playback][:format]
      else
        [r[:playback][:format]]
      end
      r.delete(:playback)
    end

    api_res[:recordings].sort_by { |rec| rec[:endTime] }.reverse
  end
end
