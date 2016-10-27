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

  def wait_for_moderator
    render layout: false
  end

  def admin?
    @user == current_user
  end
  helper_method :admin?

  private

  def render_meeting
    @meeting_id = params[:id]
    params[:action] = 'meetings'
    render :action => 'meetings'
  end

  def render_room
    params[:action] = 'rooms'
    @user = User.find_by(username: params[:id])
    if @user.nil?
      redirect_to root_path
      return
    end
    render :action => 'rooms'
  end

end
