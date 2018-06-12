class RoomsController < ApplicationController

  before_action :find_room, except: :create
  before_action :verify_room_ownership, only: [:start, :destroy, :home]

  META_LISTED = "gl-listed"

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
    if current_user && @room.owned_by?(current_user)
      @is_running = @room.is_running?
      @recordings = @room.recordings
    else
      render :join
    end
  end

  # POST /r/:room_uid
  def join
    opts = default_meeting_options

    # Assign join name if passed.
    if params[@room.invite_path][:join_name]
      @join_name = params[@room.invite_path][:join_name]
    else
      # Join name not passed.
      return
    end

    if @room.is_running?
      if current_user
        redirect_to @room.join_path(current_user.name, opts, current_user.uid)
      else
        join_name = params[@room.invite_path][:join_name]
        redirect_to @room.join_path(join_name, opts)
      end
    else
      # They need to wait until the meeting begins.
      render :wait
    end
  end

  # DELETE /r/:room_uid
  def destroy
    # Don't delete the users home room.
    @room.destroy if @room != current_user.main_room

    redirect_to current_user.main_room
  end

  # POST /r/:room_uid/start
  def start
    # Join the user in and start the meeting.
    opts = default_meeting_options
    opts[:user_is_moderator] = true

    redirect_to @room.join_path(current_user.name, opts, current_user.uid)

    # Notify users that the room has started.
    # Delay 5 seconds to allow for server start, although the request will retry until it succeeds.
    NotifyUserWaitingJob.set(wait: 5.seconds).perform_later(@room)
  end

  # GET /r/:room_uid/logout
  def logout
    # Redirect the correct page.
    redirect_to @room
  end

  # POST /r/:room_uid/home
  def home
    current_user.main_room = @room
    current_user.save

    redirect_to @room    
  end

  # POST /r/:room_uid/:record_id
  def update_recording
    meta = {
      "meta_#{META_LISTED}": (params[:state] == "public")
    }
    puts '-------------'
    puts params[:record_id]
    res = @room.update_recording(params[:record_id], meta)
    puts res
    redirect_to @room if res[:updated]
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
    @room = Room.find_by!(uid: params[:room_uid])
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
