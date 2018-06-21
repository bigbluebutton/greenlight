class MainController < ApplicationController

  #before_action :redirect_to_room

  # GET /
  def index
  end

  private

  def redirect_to_room
    # If the user is logged in already, move them along to their room.
    redirect_to room_path(current_user.room) if current_user
  end
end
