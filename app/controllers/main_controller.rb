# frozen_string_literal: true

class MainController < ApplicationController
  # before_action :redirect_to_room

  # GET /
  def index
    if Rails.env.production? && !current_user
      redirect_to "#{Rails.configuration.relative_url_root}/auth/bn_launcher"
    end
  end

  private

  def redirect_to_room
    # If the user is logged in already, move them along to their room.
    redirect_to room_path(current_user.room) if current_user
  end
end
