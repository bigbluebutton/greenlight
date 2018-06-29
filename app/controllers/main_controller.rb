# frozen_string_literal: true

class MainController < ApplicationController
  # before_action :redirect_to_room

  # GET /
  def index
    if current_user
      # Redirect authenticated users to their room.
      redirect_to room_path(current_user.room)
    else
      # Redirect unauthenticated users to root.
      #TODO use env? for launcher login endpoint
      redirect_to "#{Rails.configuration.relative_url_root}/auth/bn_launcher"
    end
  end

  private

  def redirect_to_room
    # If the user is logged in already, move them along to their room.
    redirect_to room_path(current_user.room) if current_user
  end
end
