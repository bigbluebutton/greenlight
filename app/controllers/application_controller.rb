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

class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Returns the current signed in User (if any)
  def current_user
    return @current_user if @current_user

    # Overwrites the session cookie if an extended_session cookie exists
    session[:session_token] ||= cookies.encrypted[:_extended_session]['session_token'] if cookies.encrypted[:_extended_session].present?

    user = User.find_by(session_token: session[:session_token])

    if user && invalid_session?(user)
      session[:session_token] = nil
      cookies.delete :_extended_session
      return nil
    end

    @current_user = user
  end

  # Returns whether hcaptcha is enabled by checking if ENV variables are set
  def hcaptcha_enabled?
    ENV['HCAPTCHA_SITE_KEY'].present? && ENV['HCAPTCHA_SECRET_KEY'].present?
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

    Room.create(name: t('room.new_room_name', username: user.name, locale: user.language), user_id: user.id)
  end

  # Include user domain in lograge logs
  def append_info_to_payload(payload)
    super
    payload[:host] = @current_provider
  end

  private

  # Checks if the user's session_token matches the session and that it is not expired
  def invalid_session?(user)
    return true if user&.session_token != session[:session_token]
    return true if user&.session_expiry && DateTime.now > user&.session_expiry
    return true if !user.super_admin? && user.provider != current_provider

    false
  end

  # Parses the url for the user domain
  def parse_user_domain(hostname)
    tenant = hostname&.split('.')&.first
    raise 'Invalid domain' unless Tenant.exists?(name: tenant)

    tenant
  end
end
