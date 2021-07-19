
require 'json'
class StreamingController < ApplicationController
  # Initialize Global variable pid
  def streaming_status(uid)
    json_file = "/usr/src/app/streaming_stats/#{uid}.json"
    status_file = File.file?(json_file) ? JSON.load(File.read(json_file)) : false
    return status_file
  end

  def update_status_file(json_data, uid)
    json_file = "/usr/src/app/streaming_stats/#{uid}.json"
    if (File.file?(json_file))
      File.write(json_file, JSON.dump(json_data))
      logger.error "Updated streaming status file for : #{json_data["meeting_name"]}"
    else
      File.new(json_file)
      File.write(json_file, json_data)
      meeting_id = json_data["meeting_name"]
      logger.error "Streaming status file created for : #{meeting_id}"
    end
  end

  #method to render streaming page i.e "get /streaming"  
  def show
    @streaming = Streaming.new
    @user = User.find_by(id: session[:user_id])
    if @user.streaming
      uid = @user.uid
    json_file = "/usr/src/app/streaming_stats/#{uid}.json"
    json_data = {"pid" => 0, "running" => false, "streaming_enabled" => @user.streaming}
    streaming_running = streaming_status(uid)
    streaming_running ? streaming_running["pid"] : File.new(json_file, 'w').syswrite(JSON.dump(json_data))
    render 'streaming/create'
    else
      render "errors/greenlight_error", status: 403, formats: :html,
      locals: {
        status_code: 403,
        message: "Streaming is disabled",
        help:"Please contact admin for more details",
      }

  end
  end

  # It returns id the any room that belongs to current user is running?
  def streaming_running_meetings
    user_running_rooms = {}
    current_user.ordered_rooms.each do |room|
      user_running_rooms.store(room.bbb_id, room.name) if room_running?(room.bbb_id)
    end
    return user_running_rooms
  end
  helper_method :streaming_running_meetings
  
  # streaming starts here i.e "post /streaming"
  def create
    @streaming = Streaming.new(streaming_params)
    @room = Room.find_by(bbb_id: @streaming.meeting_id)
    @user = User.find_by(id: session[:user_id])
    streaming_status = streaming_status(@user.uid)
    status_file_update_data = streaming_status ? streaming_status : {} 
    pid = streaming_status ? streaming_status["pid"] : 0 
    if (params[:commit] == "Start") && (pid == 0) 
      bbb_url = Rails.configuration.bigbluebutton_endpoint
      bbb_secret = Rails.configuration.bigbluebutton_secret
      meetingID = @streaming.meeting_id
      attendee_pw = @room.attendee_pw
      show_presentation =  @streaming.show_presentation == "1" ? "true" : "false" 
      hide_chat = Rails.configuration.hide_chat
      hide_user_list = Rails.configuration.hide_user_list
      rtmp_url =   @streaming.url.ends_with?("/") ? @streaming.url : @streaming.url + "/"
      streaming_key = @streaming.streaming_key
      full_rtmp_url = rtmp_url + streaming_key
      viewer_url = @streaming.viewer_url
      start_streaming = "node /usr/src/app/bbb-live-streaming/bbb_stream.js #{bbb_url} #{bbb_secret} #{meetingID} #{attendee_pw} #{show_presentation} #{hide_chat} #{hide_user_list} #{full_rtmp_url} #{viewer_url}"
      pid = Process.spawn (start_streaming)
      Process.detach(pid)
      running = true
      status_file_update_data = {
        "pid" => pid,
        "meeting_name" => @room.name,
        "rtmp_url" => rtmp_url,
        "viewer_url" => viewer_url,
        "meeting_id" => meetingID,
        "streaming_key" => streaming_key,
        "running" => running,
        "show_presentation" => show_presentation,
        "streaming_enabled" => @user.streaming
      }

      update_status_file(status_file_update_data, @user.uid)
      logger.info "Streaming started at pid: #{pid}"
      flash.now[:success] = ("Streaming started successfully")

    elsif (params[:commit] == "Stop") && (status_file_update_data["running"])
      begin
        Process.kill('SIGTERM', status_file_update_data["pid"].to_i)
        logger.info "Streaming stopped; killed streaming processed, pid: #{pid}"
        pid = 0
        running = false
      rescue => exception
        pid = 0
        running = false
      end
      status_file_update_data["running"] = running
      status_file_update_data["pid"] = pid
      update_status_file(status_file_update_data, @user.uid)
      flash.now[:success] = ("Streaming stopped successfully")
    end
  end
  def streaming_data
    @user = User.find_by(id: session[:user_id])
    current_streaming_data = streaming_status(@user.uid)
    return current_streaming_data
  end
  helper_method :streaming_data

  # only pass allowed params from "post /streaming"
  def streaming_params
    parameters = Streaming.attribute_names - %w(id created_at updated_at)
    params.require(:streaming).permit(parameters)
  end
end
