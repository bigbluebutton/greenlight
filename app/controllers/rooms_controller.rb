class RoomsController < ApplicationController

  before_action :find_room, :verify_room_ownership
  skip_before_action :verify_room_ownership, only: [:join, :wait]

  # GET /rooms/:room_uid
  def index

  end

  # GET /rooms/:room_uid/join
  def join
    if @meeting
      opts = default_meeting_options
      if @meeting.is_running?
        if current_user
          # Check if the current user is the room/session owner.
          opts[:user_is_moderator] = @meeting.room.owned_by?(current_user)
          redirect_to @meeting.join_path(current_user.name, opts)
        else
          # If the unauthenticated user has supplied a join name.
          if params[:join_name]
            redirect_to @meeting.join_path(params[:join_name], opts)
          else
            # Render the join page so they can supply their name.
            render :join
          end
        end
      else
        # Only start the meeting if owner is joining first.
        if current_user && @room.owned_by?(current_user)
          opts[:user_is_moderator] = true
          redirect_to @meeting.join_path(current_user.name, opts)
        else
          # Send the user to a polling page that will auto join them when it starts.
          # The wait action/page handles input of name for unauthenticated users.
          redirect_to wait_room_path(room_uid: @room.uid)
        end
      end
    else
      # Handle room doesn't exist.
  
    end
  end

  # GET /rooms/:room_uid/wait
  def wait
    if @room
      if @meeting.is_running?
        if current_user
          # If they are logged in and waiting, use their account name.
          redirect_to @meeting.join_path(current_user.name, default_meeting_options)
        elsif !params[:unauthenticated_join_name].blank?
          # Otherwise, use the name they submitted on the wating page.
          redirect_to @meeting.join_path(params[:unauthenticated_join_name], default_meeting_options)
        end
      end
    else
      # Handle room doesn't exist.
  
    end
  end

  private

  # Find the room from the uid.
  def find_room
    @room = Room.find_by(uid: params[:room_uid])
    @meeting = @room.meeting
  end

  # Default, unconfigured meeting options.
  def default_meeting_options
    {
      user_is_moderator: false,
      meeting_logout_url: request.base_url + room_path(room_uid: @room.uid),
      meeting_recorded: true,
      moderator_message: "To invite someone to the meeting, send them this link:
        #{request.base_url + join_room_path(room_uid: @room.uid)}"
    }
  end
end