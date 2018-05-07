class RoomsController < ApplicationController

  before_action :verify_room_ownership

  # GET /rooms/:room_uid
  def index
    @meeting = Meeting.new
  end
end
