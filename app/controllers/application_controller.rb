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
require 'json'
require 'digest/sha1'

class ApplicationController < ActionController::Base
  include Pagy::Backend

  # protect_from_forgery with: :null_session, if: Proc.new { |c| x_authenticity_token_match }
  protect_from_forgery with: :exception, if: Proc.new { |c| c.request.format == 'application/json' && !c.request.get? && !x_authenticity_token }

  # Returns the current signed in User (if any)
  def current_user
    return @current_user if @current_user

    # Overwrites the session cookie if an extended_session cookie exists
    session[:session_token] ||= cookies.encrypted[:_extended_session]['session_token'] if cookies.encrypted[:_extended_session].present?

    user = User.find_by(session_token: session[:session_token])

    # Process token from request
    token = bearer_token
    if !user && token
      uri = URI.parse(ENV.fetch('OPENID_CONNECT_ISSUER') + '/oidc/me')
      
      response = Net::HTTP.post(uri, data = nil, initheader = { 'Authorization' => 'Bearer ' + token })

      if response.is_a?(Net::HTTPSuccess)
        result = JSON.parse(response.body)
        user = User.find_by(email: result['email'])
      end
    end

    if user && !token && invalid_session?(user)
      session[:session_token] = nil
      cookies.delete :_extended_session
      return nil
    end

    @current_user = user
  end

  # Returns whether hcaptcha is enabled by checking if ENV variables are set
  def hcaptcha_enabled?
    (ENV['HCAPTCHA_SITE_KEY'].present? && ENV['HCAPTCHA_SECRET_KEY'].present?)
  end

  # Returns the current provider value
  def current_provider
    @current_provider ||= if ENV['LOADBALANCER_ENDPOINT'].present?
                            parse_user_domain(request.host)
                          else
                            'greenlight'
                          end
  end
  helper_method :current_provider

  # Returns the default role
  def default_role
    default_role_setting = SettingGetter.new(setting_name: 'DefaultRole', provider: current_provider).call
    @default_role = Role.find_by(name: default_role_setting, provider: current_provider) || Role.find_by(name: 'User', provider: current_provider)
  end

  # Creates the default room for the user if they don't already have one
  def create_default_room(user)
    return unless user.rooms.count <= 0
    return unless PermissionsChecker.new(permission_names: 'CreateRoom', user_id: user.id, current_user: user, current_provider:).call

    Room.create(name: "#{user.name}'s Room", user_id: user.id)
  end

  # Include user domain in lograge logs
  def append_info_to_payload(payload)
    super
    payload[:host] = @current_provider
  end

  private

  # Get bearer token if exists
  def bearer_token
    pattern = /^Bearer /
    header  = request.headers['Authorization']

    if header && header.match(pattern)
      token = header.gsub(pattern, '')
    else
      token = false
    end

    token
  end

  # Check authenticity token if exists
  def x_authenticity_token
    csrf_token = request.headers['X-CSRF-TOKEN']
    
    if csrf_token.present?
      return true
    end
    
    pattern = /^Secret /
    header  = request.headers['X-Authenticity-Secret']

    if header && header.match(pattern)
      token = header.gsub(pattern, '')
    else
      return false
    end

    secret = ENV.fetch('SECRET_KEY_BASE')
    parsed = JSON[request.body.to_json][0]
    str_to_hash = "#{parsed}-#{secret}"
    body_hash = Digest::SHA1.hexdigest(str_to_hash)

    return false if token != body_hash

    return true
  end  

  # Checks if the user's session_token matches the session and that it is not expired
  def invalid_session?(user)
    return true if user&.session_token != session[:session_token]
    return true if user&.session_expiry && DateTime.now > user&.session_expiry

    false
  end

  # Parses the url for the user domain
  def parse_user_domain(hostname)
    tenant = hostname&.split('.')&.first
    raise 'Invalid domain' unless Tenant.exists?(name: tenant)

    tenant
  end
end
