class LandingController < ApplicationController

  def meeting
    @refreshable = (params[:resource] == 'meetings' && !params.has_key?(:id))
    @meeting_token = params[:id] || @meeting_token = helpers.new_meeting_token
    @resource_url = meeting_url(@meeting_token)
  end

  # GET /token.json
  def new_meeting
    respond_to do |format|
      meeting_url = meeting_url(helpers.new_meeting_token)
      format.json { render :json => { :messageKey => "ok", :message => "New meeting URL created", :status => :ok, :response => { :meeting_url => meeting_url} }, :status => status }
    end
  end

  def room
    @room_name = params[:name]
    @meeting_token = @room_name
    @resource_url = room_url(@meeting_token)
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
