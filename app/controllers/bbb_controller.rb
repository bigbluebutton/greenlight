class BbbController < ApplicationController

  before_action :authorize_owner_recording, only: [:update_recordings, :delete_recordings]

  # GET /:resource/:id/join
  def join
    if params[:name].blank?
      render_bbb_response("missing_parameter", "user name was not included", :unprocessable_entity)
    else
      user = User.find_by username: params[:id]

      options = if user
        {
          wait_for_moderator: true,
          meeting_recorded: true,
          user_is_moderator: current_user == user
        }
      else
        {}
      end
      options[:meeting_logout_url] = "#{request.base_url}/#{params[:resource]}/#{params[:id]}"

      bbb_res = helpers.bbb_join_url(
        params[:id],
        params[:name],
        options
      )

      if bbb_res[:returncode] && current_user && current_user == user
        ActionCable.server.broadcast "moderator_#{user.username}_join_channel",
          moderator: "joined"
      end

      render_bbb_response bbb_res, bbb_res[:response]
    end
  end

  # GET /rooms/:id/recordings
  def recordings
    user = User.find_by username: params[:id]
    if !user
      render head(:not_found) && return
    end

    bbb_res = helpers.bbb_get_recordings user.username
    render_bbb_response bbb_res, bbb_res[:recordings]
  end

  # PATCH /rooms/:id/recordings/:record_id
  def update_recordings
    bbb_res = helpers.bbb_update_recordings(params[:record_id], params[:published] == 'true')
    render_bbb_response bbb_res, bbb_res[:recordings]
  end

  # DELETE /rooms/:id/recordings/:record_id
  def delete_recordings
    byebug
    bbb_res = helpers.bbb_delete_recordings(params[:record_id])
    render_bbb_response bbb_res, bbb_res[:recordings]
  end

  private

  def authorize_owner_recording
    user = User.find_by username: params[:id]
    if !user
      render head(:not_found) && return
    elsif !current_user || current_user != user
      render head(:unauthorized) && return
    end

    recordings = helpers.bbb_get_recordings(params[:record_id])[:recordings]
    recordings.each do |recording|
      if recording[:recordID] == params[:record_id]
        return true
      end
    end
    render head(:not_found) && return
  end

  def render_bbb_response(bbb_res, response)
    @messageKey = bbb_res[:messageKey]
    @message = bbb_res[:message]
    @status = bbb_res[:status]
    @response = response
    render status: @status && return
  end
end
