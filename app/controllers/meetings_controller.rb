class MeetingsController < ApplicationController

  #before_action :verify_room_ownership

  # GET /r/:room_uid/meetings
  def index
  end

  private

  #def meeting_params(room)
  #  params.require(:meeting).permit(:name).merge!(room: room)
  #end
end
