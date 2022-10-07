# frozen_string_literal: true

class ExternalController < ApplicationController
  skip_before_action :verify_authenticity_token

  # GET 'auth/:provider/callback'
  def create_user
    provider = current_provider

    credentials = request.env['omniauth.auth']
    user_info = {
      name: credentials['info']['name'],
      email: credentials['info']['email'],
      language: extract_language_code(credentials['info']['locale'])
    }

    user = User.find_or_create_by!(external_id: credentials['uid'], provider:) do |u|
      user_info[:role] = Role.find_by(name: 'User')
      u.assign_attributes(user_info)
    end

    if SettingGetter.new(setting_name: 'ResyncOnLogin', provider:).call
      user.assign_attributes(user_info)
      user.save! if user.changed?
    end

    user.generate_session_token!
    session[:session_token] = user.session_token

    # TODO: - Ahmad: deal with errors

    redirect_location = cookies[:location]
    cookies.delete(:location)
    return redirect_to redirect_location if redirect_location&.match?('\/rooms\/\w{3}-\w{3}-\w{3}-\w{3}\/join')

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
    @room.update(recordings_processing: @room.recordings_processing + 1, online: false)

    render json: {}, status: :ok
  end

  private

  def extract_language_code(locale)
    locale.try(:scan, /^[a-z]{2}/)&.first || I18n.default_locale
  end
end
