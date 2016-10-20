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

  # GET /token.json
  def new_meeting
    respond_to do |format|
      meeting_url = resource_url('meetings', helpers.new_meeting_token)
      format.json { render :json => { :messageKey => "ok", :message => "New meeting URL created", :status => :ok, :response => { :meeting_url => meeting_url} }, :status => status }
    end
  end

  def meeting
    render_meeting
  end

  def admin?
    @user == current_user
  end
  helper_method :admin?

  private

  def render_meeting
    @resource = params[:resource]
    @meeting_token = params[:id] || @meeting_token = helpers.new_meeting_token
    @refreshable = (params[:resource] == 'meetings' && !params.has_key?(:id))
    render :action => 'meeting'
  end

  def render_room
    @resource = params[:resource]
    @meeting_token = params[:id]
    @user = User.find_by(username: @meeting_token)
    if @user.nil?
      redirect_to root_path
      return
    end
    render :action => 'room'
  end

end
