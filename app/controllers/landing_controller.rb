class LandingController < ApplicationController
  include BbbApi

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

  def session_status_refresh
    @user = User.find_by(username: params[:id])
    if @user.nil?
      render head(:not_found) && return
    end

    @meeting_running = bbb_get_meeting_info(@user.username)[:returncode]

    render layout: false
  end

  def admin?
    @user && @user == current_user
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

    @meeting_running = bbb_get_meeting_info(@user.username)[:returncode]

    render :action => 'rooms'
  end

end
