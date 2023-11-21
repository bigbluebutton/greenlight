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

# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  issuer = ENV.fetch('OPENID_CONNECT_ISSUER', '')
  lb = ENV.fetch('LOADBALANCER_ENDPOINT', '')

  if lb.present?
    provider :openid_connect, setup: lambda { |env|
      request = Rack::Request.new(env)
      current_provider = request.params['current_provider'] || request.host&.split('.')&.first
      secret = Tenant.find_by(name: current_provider)&.client_secret
      issuer_url = File.join issuer.to_s, "/#{current_provider}"

      env['omniauth.strategy'].options[:issuer] = issuer_url
      env['omniauth.strategy'].options[:scope] = %i[openid email profile]
      env['omniauth.strategy'].options[:uid_field] = ENV.fetch('OPENID_CONNECT_UID_FIELD', 'sub')
      env['omniauth.strategy'].options[:discovery] = true
      env['omniauth.strategy'].options[:client_options].identifier = ENV.fetch('OPENID_CONNECT_CLIENT_ID')
      env['omniauth.strategy'].options[:client_options].secret = secret
      env['omniauth.strategy'].options[:client_options].redirect_uri = File.join(
        File.join('https://', "#{current_provider}.#{ENV.fetch('OPENID_CONNECT_REDIRECT', '')}", 'auth', 'openid_connect', 'callback')
      )
      env['omniauth.strategy'].options[:client_options].authorization_endpoint = File.join(issuer_url, 'protocol', 'openid-connect', 'auth')
      env['omniauth.strategy'].options[:client_options].token_endpoint = File.join(issuer_url, 'protocol', 'openid-connect', 'token')
      env['omniauth.strategy'].options[:client_options].userinfo_endpoint = File.join(issuer_url, 'protocol', 'openid-connect', 'userinfo')
      env['omniauth.strategy'].options[:client_options].jwks_uri = File.join(issuer_url, 'protocol', 'openid-connect', 'certs')
      env['omniauth.strategy'].options[:client_options].end_session_endpoint = File.join(issuer_url, 'protocol', 'openid-connect', 'logout')
    }
  elsif issuer.present?
    provider :openid_connect,
             issuer:,
             scope: %i[openid email profile],
             uid_field: ENV.fetch('OPENID_CONNECT_UID_FIELD', 'sub'),
             discovery: true,
             client_options: {
               identifier: ENV.fetch('OPENID_CONNECT_CLIENT_ID'),
               secret: ENV.fetch('OPENID_CONNECT_CLIENT_SECRET'),
               redirect_uri: File.join(ENV.fetch('OPENID_CONNECT_REDIRECT', ''), 'auth', 'openid_connect', 'callback')
             }
  end
end
