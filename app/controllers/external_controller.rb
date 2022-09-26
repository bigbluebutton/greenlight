# frozen_string_literal: true

class ExternalController < ApplicationController
  # GET 'auth/:provider/callback'
  def create_user
    credentials = request.env['omniauth.auth']
    user_info = credentials['info']
    user = User.find_or_create_by(email: user_info['email']) do |u|
      u.external_id = credentials['uid']
      u.name = user_info['name']
      u.provider = current_provider
      u.role = Role.find_by(name: 'User') # TODO: - Ahmad: Move to service
      u.language = extract_language_code user_info['locale']
    end

    user.generate_session_token!
    session[:session_token] = user.session_token

    # TODO: - Ahmad: deal with errors

    redirect_to '/rooms'
  end

  # POST /recording_ready
  def recording_ready
    response = BigBlueButtonApi.new.decode_jwt(params[:signed_parameters])
    record_id = response[0]['record_id']
    recording = BigBlueButtonApi.new.get_recording(record_id:)

    # Only decrement if the recording doesn't already exist
    # This is needed to handle duplicate requests
    unless Recording.exists?(record_id:)
      @room = Room.find_by(meeting_id: response[0]['meeting_id'])
      @room.update(recordings_processing: @room.recordings_processing - 1)
    end

    RecordingCreator.new(recording:).call

    render json: {}, status: :ok
  end

  # GET /meeting_ended
  def meeting_ended
    return render json: {} unless params[:recordingmarks] == 'true'

    @room = Room.find_by(meeting_id: params[:meetingID])
    @room.update(recordings_processing: @room.recordings_processing + 1)

    render json: {}, status: :ok
  end

  private

  def extract_language_code(locale)
    locale.try(:scan, /^[a-z]{2}/)&.first || I18n.default_locale
  end
end
