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

require 'bigbluebutton_api'

class ApplicationController < ActionController::Base
  include SessionsHelper
  include ThemingHelper

  before_action :migration_error?
  before_action :set_locale
  before_action :check_admin_password
  before_action :set_user_domain
  before_action :check_if_unbanned

  # Force SSL for loadbalancer configurations.
  before_action :redirect_to_https

  protect_from_forgery with: :exception

  MEETING_NAME_LIMIT = 90
  USER_NAME_LIMIT = 32

  # Show an information page when migration fails and there is a version error.
  def migration_error?
    render :migration_error unless ENV["DB_MIGRATE_FAILED"].blank?
  end

  # Sets the appropriate locale.
  def set_locale
    update_locale(current_user)
  end

  def update_locale(user)
    locale = if user && user.language != 'default'
      user.language
    else
      http_accept_language.language_region_compatible_from(I18n.available_locales)
    end
    I18n.locale = locale.tr('-', '_') unless locale.nil?
  end

  def meeting_name_limit
    MEETING_NAME_LIMIT
  end
  helper_method :meeting_name_limit

  def user_name_limit
    USER_NAME_LIMIT
  end
  helper_method :user_name_limit

  # Relative root helper (when deploying to subdirectory).
  def relative_root
    Rails.configuration.relative_url_root || ""
  end
  helper_method :relative_root

  # Determines if the BigBlueButton endpoint is configured (or set to default).
  def bigbluebutton_endpoint_default?
    return false if Rails.configuration.loadbalanced_configuration
    Rails.configuration.bigbluebutton_endpoint_default == Rails.configuration.bigbluebutton_endpoint
  end
  helper_method :bigbluebutton_endpoint_default?

  def recording_thumbnails?
    Rails.configuration.recording_thumbnails
  end
  helper_method :recording_thumbnails?

  def allow_greenlight_users?
    Rails.configuration.greenlight_accounts
  end
  helper_method :allow_greenlight_users?

  # Determines if a form field needs the is-invalid class.
  def form_is_invalid?(obj, key)
    'is-invalid' unless obj.errors.messages[key].empty?
  end
  helper_method :form_is_invalid?

  # Default, unconfigured meeting options.
  def default_meeting_options
    invite_msg = I18n.t("invite_message")
    {
      user_is_moderator: false,
      meeting_logout_url: request.base_url + logout_room_path(@room),
      meeting_recorded: true,
      moderator_message: "#{invite_msg}\n\n#{request.base_url + room_path(@room)}",
    }
  end

  # Manually deal with 401 errors
  rescue_from CanCan::AccessDenied do |_exception|
    render "errors/not_found"
  end

  # Checks to make sure that the admin has changed his password from the default
  def check_admin_password
    if current_user&.has_role?(:admin) && current_user&.greenlight_account? &&
       current_user&.authenticate(Rails.configuration.admin_password_default)

      flash.now[:alert] = I18n.t("default_admin",
        edit_link: edit_user_path(user_uid: current_user.uid) + "?setting=password").html_safe
    end
  end

  def redirect_to_https
    if Rails.configuration.loadbalanced_configuration && request.headers["X-Forwarded-Proto"] == "http"
      redirect_to protocol: "https://"
    end
  end

  def set_user_domain
    @user_domain = if Rails.env.test? || !Rails.configuration.loadbalanced_configuration
      "greenlight"
    else
      parse_user_domain(request.host)
    end
  end
  helper_method :set_user_domain

  # Checks if the user is banned and logs him out if he is
  def check_if_unbanned
    if current_user&.has_role?(:denied)
      session.delete(:user_id)
      redirect_to unauthorized_path
    end
  end
  helper_method :check_if_unbanned
end
