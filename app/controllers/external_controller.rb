# frozen_string_literal: true

class ExternalController < ApplicationController
  skip_before_action :verify_authenticity_token

  # GET 'auth/:provider/callback'
  def create_user
    resync = SettingGetter.new(setting_name: 'ResyncOnLogin', provider: current_provider).call

    credentials = request.env['omniauth.auth']
    user_info = credentials['info']

    user = if resync
             User.find_or_initialize_by(external_id: credentials['uid']).tap do |u|
               u.email = user_info['email']
               u.name = user_info['name']
               u.provider = current_provider
               u.role = Role.find_by(name: 'User') # TODO: - Ahmad: Move to service
               u.language = extract_language_code user_info['locale']
               u.save!
             end
           else
             User.find_or_create_by(external_id: credentials['uid']) do |u|
               u.email = user_info['email']
               u.name = user_info['name']
               u.provider = current_provider
               u.role = Role.find_by(name: 'User') # TODO: - Ahmad: Move to service
               u.language = extract_language_code user_info['locale']
             end
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
    @room.update(recordings_processing: @room.recordings_processing + 1, online: false)

    render json: {}, status: :ok
  end

  private

  def extract_language_code(locale)
    locale.try(:scan, /^[a-z]{2}/)&.first || I18n.default_locale
  end
end
