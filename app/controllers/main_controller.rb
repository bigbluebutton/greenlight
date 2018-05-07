class MainController < ApplicationController

  # GET /
  def index
    # If the user is logged in already, move them along to their room.
    redirect_to room_path(current_user.room.uid) if current_user
  end

end
