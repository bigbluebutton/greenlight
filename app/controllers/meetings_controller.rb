class MeetingsController < ApplicationController

  before_action :verify_room_ownership
  skip_before_action :verify_room_ownership, only: [:join, :wait]

  # GET /rooms/:room_uid/meetings
  def index

  end

  # GET /rooms/:room_uid/meetings/:meeting_uid
  def show

  end
  
  # POST /rooms/:room_uid/meetings
  def create
    @meeting = Meeting.new(meeting_params(@room))

    if @meeting.save
      # Create the meeting on the BigBlueButton server and join the user into the meeting.
      redirect_to join_meeting_path(room_uid: @room.uid, meeting_uid: @meeting.uid)
    else
      # Meeting couldn't be created, handle error.

    end
  end

  # GET /rooms/:room_uid/meetings/:meeting_uid/join
  def join
    @meeting = Meeting.find_by(uid: params[:meeting_uid])

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
            # Render the join page so they can supploy their name.
            render :join
          end
        end
      else
        # Only start the meeting if owner is joining first.
        if current_user && @meeting.room.owned_by?(current_user)
          opts[:user_is_moderator] = true
          redirect_to @meeting.join_path(current_user.name, opts)
        else
          # Send the user to a polling page that will auto join them when it starts.
          # The wait action/page handles input of name for unauthenticated users.
          render :wait
        end
      end
    end
  end

  # GET /rooms/:room_uid/meetings/:meeting_uid/wait
  def wait

  end

  private

  def meeting_params(room)
    params.require(:meeting).permit(:name).merge!(room_id: room.id)
  end

  def default_meeting_options
    {
      user_is_moderator: false,
      meeting_logout_url: request.base_url + room_path(room_uid: @meeting.room.uid),
      moderator_message: "To invite someone to the meeting, send them this link:
        #{request.base_url + join_meeting_path(room_uid: @meeting.room.uid, meeting_uid: @meeting.uid)}"
    }
  end
end
