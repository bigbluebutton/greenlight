class MeetingsController < ApplicationController

  # GET /m/:meeting_uid
  def show
    @meeting = Meeting.find_by(uid: params[:meeting_uid])
    if @meeting
      
    else
      # Handle meeting doesn't exist.
      
    end
  end

  # POST /m/:meeting_uid
  def join
    meeting = Meeting.find_by(uid: params[:meeting_uid])
    if meeting
      # If the user is logged in, join using their authenticated name.
      if current_user
        redirect_to meeting.join_path(current_user.name)
      # Otherwise, use their inputed join name.
      elsif params[:join_name]
        redirect_to meeting.join_path(params[:join_name])
      end
    else
      # Handle meeting doesn't exist.

    end
  end

  # POST /m
  def create
    meeting = Meeting.new(meeting_params)
    if meeting.save
      redirect_to meeting_path(meeting_uid: meeting.uid)
    else
      redirect_to root_path
    end
  end

  private

  def meeting_params
    params.require(:meeting).permit(:name)
  end
end
