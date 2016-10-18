class LandingController < ApplicationController

  def index
    @refreshable = (params[:resource] == 'meeting' && !params.has_key?(:id))
    @meeting_token = params[:id] || @meeting_token = helpers.new_meeting_token
    @meeting_url = landing_url(@meeting_token)
  end

  # GET /token.json
  def new_meeting
    respond_to do |format|
      meeting_url = landing_url(helpers.new_meeting_token)
      format.json { render :json => { :messageKey => "ok", :message => "New meeting URL created", :status => :ok, :response => { :meeting_url => meeting_url} }, :status => status }
    end
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
