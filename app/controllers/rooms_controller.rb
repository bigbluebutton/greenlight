class RoomsController < ApplicationController

  before_action :find_room, except: :create

  #before_action :verify_room_ownership
  #skip_before_action :verify_room_ownership, only: [:create, :show, :join, :wait]

  # POST /r
  def create
    room = Room.new(name: room_params[:name])
    room.owner = current_user

    if room.save
      if room_params[:auto_join] == "1"
        redirect_to start_room_path(room)
      else
        redirect_to room
      end
    else
      # Handle room didn't save.

    end
  end

  # GET /r/:room_uid
  def show
    opts = default_meeting_options

    if @room.is_running?
      if current_user
        # If you don't own the room but the meeting is running, join up.
        if !@room.owned_by?(current_user)
          opts[:user_is_moderator] = false
          redirect_to @room.join_path(current_user, opts)
        end
      else
        # Render the join page so they can supply their name.
        render :join
      end
    else
      # If the room isn't running, go to join page to enter a name.
      if !@room.owned_by?(current_user)
        render :join
      end

      # If the meeting isn't running and you don't own the room, go to the waiting page.
      #if !@room.owned_by?(current_user)
      #  redirect_to wait_room_path(@room)
      #end
    end

    # NOTE: TEST TO MAKE SURE THIS DOESN'T FIRE WHEN THEY ARE NOT OWNER AND REDIRECTED.
    @recordings = @room.recordings
  end

  # POST /r/:room_uid
  def join
    opts = default_meeting_options

    if @room.is_running?
      # If you're unauthenticated, you must enter a name to join the meeting.
      if params[@room.invite_path][:join_name]
        redirect_to @room.join_path(params[@room.invite_path][:join_name], opts)
      else
        redirect_to @room.join_path(current_user, opts)
      end
    else
      # They need to wait until the meeting begins.

    end
  end

  # DELETE /r/:room_uid
  def destroy
    # Don't delete the users home room.
    @room.destroy if @room != current_user.main_room

    redirect_to current_user.main_room
  end

  # GET /r/:room_uid/start
  def start
    # Join the user in and start the meeting.
    opts = default_meeting_options
    opts[:user_is_moderator] = true

    redirect_to @room.join_path(current_user, opts)
  end

  # GET/POST /r/:room_uid/wait
  def wait
    if @room.is_running?
      if current_user
        # If they are logged in and waiting, use their account name.
        redirect_to @room.join_path(current_user, default_meeting_options)
      elsif !params[:unauthenticated_join_name].blank?
        # Otherwise, use the name they submitted on the wating page.
        redirect_to @room.join_path(params[:unauthenticated_join_name], default_meeting_options)
      end
    end
  end

  # GET /r/:room_uid/logout
  def logout
    # Redirect the owner to their room.
    if current_user
      redirect_to current_user.main_room
    else
      redirect_to root_path
    end
  end

  # GET /r/:room_uid/sessions
  def sessions

  end

  # POST /r/:room_uid/home
  def home
    current_user.main_room = @room
    current_user.save

    redirect_to @room    
  end

  # DELETE /r/:room_uid/:record_id
  def delete_recording
    @room.delete_recording(params[:record_id])

    redirect_to current_user.main_room
  end

  # Helper for converting BigBlueButton dates into the desired format.
  def recording_date(date)
    date.strftime("%B #{date.day.ordinalize}, %Y.")
  end
  helper_method :recording_date

  # Helper for converting BigBlueButton dates into a nice length string.
  def recording_length(start_time, end_time)
    len = ((end_time - start_time) * 24 * 60).to_i

    if len > 60
      "#{len / 60} hrs"
    else
      if len == 0
        "< 1 min"
      else
        "#{len} min"
      end
    end
  end
  helper_method :recording_length

  private

  def room_params
    params.require(:room).permit(:name, :auto_join)
  end

  # Find the room from the uid.
  def find_room
    @room = Room.find_by(uid: params[:room_uid])

    if @room.nil?
      # Handle room doesn't exist.

    end
  end

  # Ensure the user is logged into the room they are accessing.
  def verify_room_ownership
    bring_to_room if !@room.owned_by?(current_user)
  end

  # Redirects a user to their room.
  def bring_to_room
    if current_user
      # Redirect authenticated users to their room.
      redirect_to room_path(current_user.room.uid)
    else
      # Redirect unauthenticated users to root.
      redirect_to root_path
    end
  end
end
