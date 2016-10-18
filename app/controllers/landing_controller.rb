class LandingController < ApplicationController
  include LandingHelper

  def index
    @meeting_token = params[:id] || @meeting_token = rand.to_s[2..10]
    @meeting_url = meeting_url(@meeting_token)
  end

  def room
    @room_name = params[:name]
    @user = User.find_by(username: @room_name)
    if @user.nil?
      redirect_to root_path
    end
  end

  def admin?
    @user == current_user
  end
  helper_method :admin?
end
