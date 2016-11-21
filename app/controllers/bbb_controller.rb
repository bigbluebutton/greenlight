class BbbController < ApplicationController
  include BbbApi

  before_action :authorize_recording_owner!, only: [:update_recordings, :delete_recordings]
  before_action :load_and_authorize_room_owner!, only: [:end]

  # GET /:resource/:id/join
  def join
    if params[:name].blank?
      render_bbb_response("missing_parameter", "user name was not included", :unprocessable_entity)
    else
      user = User.find_by encrypted_id: params[:id]

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

      bbb_res = bbb_join_url(
        params[:id],
        params[:name],
        options
      )

      if bbb_res[:returncode] && current_user && current_user == user
        JoinMeetingJob.perform_later(user.encrypted_id)
      end

      render_bbb_response bbb_res, bbb_res[:response]
    end
  end

  # DELETE /rooms/:id/end
  def end
    load_and_authorize_room_owner!

    bbb_res = bbb_end_meeting @user.encrypted_id
    if bbb_res[:returncode]
      EndMeetingJob.perform_later(@user.encrypted_id)
    end
    render_bbb_response bbb_res
  end

  # GET /rooms/:id/recordings
  def recordings
    load_room!

    bbb_res = bbb_get_recordings @user.encrypted_id
    render_bbb_response bbb_res, bbb_res[:recordings]
  end

  # PATCH /rooms/:id/recordings/:record_id
  def update_recordings
    bbb_res = bbb_update_recordings(params[:record_id], params[:published] == 'true')
    if bbb_res[:returncode]
      RecordingUpdatesJob.perform_later(@user.encrypted_id, params[:record_id], bbb_res[:published])
    end
    render_bbb_response bbb_res
  end

  # DELETE /rooms/:id/recordings/:record_id
  def delete_recordings
    bbb_res = bbb_delete_recordings(params[:record_id])
    if bbb_res[:returncode]
      RecordingDeletesJob.perform_later(@user.encrypted_id, params[:record_id])
    end
    render_bbb_response bbb_res
  end

  private

  def load_room!
    @user = User.find_by encrypted_id: params[:id]
    if !@user
      render head(:not_found) && return
    end
  end

  def load_and_authorize_room_owner!
    load_room!

    if !current_user || current_user != @user
      render head(:unauthorized) && return
    end
  end

  def authorize_recording_owner!
    load_and_authorize_room_owner!

    recordings = bbb_get_recordings(params[:id])[:recordings]
    recordings.each do |recording|
      if recording[:recordID] == params[:record_id]
        return true
      end
    end
    render head(:not_found) && return
  end

  def render_bbb_response(bbb_res, response={})
    @messageKey = bbb_res[:messageKey]
    @message = bbb_res[:message]
    @status = bbb_res[:status]
    @response = response
    render status: @status
  end
end
