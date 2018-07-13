# frozen_string_literal: true

require 'bigbluebutton_api'

class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :migration_error?
  before_action :set_locale

  protect_from_forgery with: :exception

  MEETING_NAME_LIMIT = 90
  USER_NAME_LIMIT = 30

  # Show an information page when migration fails and there is a version error.
  def migration_error?
    render :migration_error unless ENV["DB_MIGRATE_FAILED"].blank?
  end

  # Sets the appropriate locale.
  def set_locale
    I18n.locale = http_accept_language.language_region_compatible_from(I18n.available_locales)
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
    return false if loadbalanced_configuration?
    Rails.configuration.bigbluebutton_endpoint_default == Rails.configuration.bigbluebutton_endpoint
  end
  helper_method :bigbluebutton_endpoint_default?

  def loadbalanced_configuration?
    Rails.configuration.loadbalanced_configuration
  end
  helper_method :loadbalanced_configuration?

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
    invite_msg = "To invite someone to the meeting, send them this link:"
    {
      user_is_moderator: false,
      meeting_logout_url: request.base_url + logout_room_path(@room),
      meeting_recorded: true,
      moderator_message: "#{invite_msg}\n\n #{request.base_url + room_path(@room)}",
    }
  end
end
