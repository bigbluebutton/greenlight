# frozen_string_literal: true

class ProviderValidator
  def initialize(provider:)
    @provider = provider
    @endpoint = File.join(ENV.fetch('LOADBALANCER_ENDPOINT'), '/api2/')
    @secret = ENV.fetch('LOADBALANCER_SECRET')
    @route = 'getUserGreenlightCredentials'
  end

  def call
    encoded_params = { name: @provider }.to_param
    checksum = Digest::SHA1.hexdigest(@route + encoded_params + @secret)

    # Cache the response for an hour
    # fetch will return the value if already cached, if not, it will compute the value, cache it, then return it
    Rails.cache.fetch("#{@provider}/#{@route}", expires_in: 1.hour) do
      url = URI.parse("#{@endpoint}#{@route}?#{encoded_params}&checksum=#{checksum}")
      res = Net::HTTP.get_response(url)

      return false unless res.is_a?(Net::HTTPSuccess)

      response = Hash.from_xml(res.body)['response']

      response['returncode'] == 'SUCCESS'
    end
  end
end
