class LandingController < ApplicationController

  def index
    if params[:resource] == 'meetings'
      render_meeting
    elsif params[:resource] == 'rooms'
      render_room
    else
      render 'errors/error'
    end
  end

  def admin?
    @user == current_user
  end
  helper_method :admin?

  private

  def render_meeting
    params[:action] = 'meetings'
    render :action => 'meeting'
  end

  def render_room
    params[:action] = 'rooms'
    @user = User.find_by(username: params[:id])
    if @user.nil?
      redirect_to root_path
      return
    end
    render :action => 'room'
  end

end
