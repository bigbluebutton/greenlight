require 'bigbluebutton_api'

class ApplicationController < ActionController::Base
  include SessionsHelper

  protect_from_forgery with: :exception

  MEETING_NAME_LIMIT = 90
  USER_NAME_LIMIT = 30

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
    'is-invalid' if !obj.errors.messages[key].empty?
  end
  helper_method :form_is_invalid?
  
  # Default, unconfigured meeting options.
  def default_meeting_options
    {
      user_is_moderator: false,
      meeting_logout_url: request.base_url + logout_room_path(@room),
      meeting_recorded: true,
      moderator_message: "To invite someone to the meeting, send them this link:\n\n
        #{request.base_url + relative_root + room_path(@room)}"
    }
  end
end
