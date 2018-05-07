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

  # Determines if the BigBlueButton endpoint is configured (or set to default).
  def bigbluebutton_endpoint_default?
    Rails.configuration.bigbluebutton_endpoint_default == Rails.configuration.bigbluebutton_endpoint
  end
  helper_method :bigbluebutton_endpoint_default?

  private

  # Ensure the user is logged into the room they are accessing.
  def verify_room_ownership
    return unless params.include?(:room_uid)
    @room = Room.find_by(uid: params[:room_uid])
  
    # Redirect to correct room or root if not logged in.
    if current_user.nil?
      redirect_to root_path
    elsif @room.nil? || current_user != @room.user
      redirect_to room_path(current_user.room.uid)
    end
  end
end
