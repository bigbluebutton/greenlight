# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.
#
# frozen_string_literal: true

class ProviderCredentials
  def initialize(provider:)
    @provider = provider
    @route = 'getUser'

    set_regional_credentials
  end

  def call
    encoded_params = { name: @provider }.to_param
    checksum = Digest::SHA1.hexdigest(@route + encoded_params + @secret)

    # Cache the response for an hour
    # fetch will return the value if already cached, if not, it will compute the value, cache it, then return it
    Rails.cache.fetch("v3/#{@provider}/#{@route}", expires_in: 1.hour) do
      url = URI.parse("#{@endpoint}#{@route}?#{encoded_params}&checksum=#{checksum}")
      res = Net::HTTP.get_response(url)

      return false unless res.is_a?(Net::HTTPSuccess)

      response = Hash.from_xml(res.body)['response']

      return false unless response['returncode'] == 'SUCCESS'

      [response['user']['apiURL'], response['user']['secret']]
    end
  end

  private

  def set_regional_credentials
    tenant = Tenant.find_by(name: @provider)

    case tenant&.region&.downcase
    when 'rna1'
      @endpoint = File.join(ENV.fetch('LOADBALANCER_ENDPOINT_RNA1'), '/api/')
      @secret = ENV.fetch('LOADBALANCER_SECRET_RNA1')
    when 'reu1'
      @endpoint = File.join(ENV.fetch('LOADBALANCER_ENDPOINT_REU1'), '/api/')
      @secret = ENV.fetch('LOADBALANCER_SECRET_REU1')
    when 'rna2'
      @endpoint = File.join(ENV.fetch('LOADBALANCER_ENDPOINT_RNA2'), '/api/')
      @secret = ENV.fetch('LOADBALANCER_SECRET_RNA2')
    when 'roc2'
      @endpoint = File.join(ENV.fetch('LOADBALANCER_ENDPOINT_ROC2'), '/api/')
      @secret = ENV.fetch('LOADBALANCER_SECRET_ROC2')
    else
      @endpoint = File.join(ENV.fetch('LOADBALANCER_ENDPOINT'), '/api/')
      @secret = ENV.fetch('LOADBALANCER_SECRET')
    end
  end
end
