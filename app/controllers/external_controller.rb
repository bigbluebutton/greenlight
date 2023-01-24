# frozen_string_literal: true

class ExternalController < ApplicationController
  skip_before_action :verify_authenticity_token

  # GET 'auth/:provider/callback'
  # Creates the user using the information received through the external auth method
  def create_user
    provider = current_provider

    credentials = request.env['omniauth.auth']
    user_info = {
      name: credentials['info']['name'],
      email: credentials['info']['email'],
      language: extract_language_code(credentials['info']['locale']),
      verified: true
    }

    user = User.find_by(external_id: credentials['uid'], provider:)
    new_user = user.blank?

    registration_method = SettingGetter.new(setting_name: 'RegistrationMethod', provider: current_provider).call

    # Check if they have a valid token only if a new sign up
    if new_user && registration_method == SiteSetting::REGISTRATION_METHODS[:invite] && !valid_invite_token(email: user_info[:email])
      raise StandardError, Rails.configuration.custom_error_msgs[:invite_token_invalid]
    end

    # Create the user if they dont exist
    user = User.create({ external_id: credentials['uid'], provider:, role: default_role }.merge(user_info)) if new_user

    if SettingGetter.new(setting_name: 'ResyncOnLogin', provider:).call
      user.assign_attributes(user_info.except(:language)) # Don't reset the user's language
      user.save! if user.changed?
    end

    user.generate_session_token!
    session[:session_token] = user.session_token

    # Set to pending if registration method is approval
    user.pending! if new_user && registration_method == SiteSetting::REGISTRATION_METHODS[:approval]

    # TODO: - Ahmad: deal with errors
    redirect_location = cookies[:location]
    cookies.delete(:location)
    return redirect_to redirect_location if redirect_location&.match?('\A\/rooms\/\w{3}-\w{3}-\w{3}-\w{3}\/join\z')

    redirect_to '/rooms'
  end

  # POST /recording_ready
  # Creates the recording in Greenlight using information received from BigBlueButton
  def recording_ready
    response = BigBlueButtonApi.new.decode_jwt(params[:signed_parameters])
    record_id = response[0]['record_id']
    recording = BigBlueButtonApi.new.get_recording(record_id:)

    # Only decrement if the recording doesn't already exist
    # This is needed to handle duplicate requests
    unless Recording.exists?(record_id:)
      @room = Room.find_by(meeting_id: response[0]['meeting_id'])
      @room.update(recordings_processing: @room.recordings_processing - 1) unless @room.recordings_processing.zero?
    end

    RecordingCreator.new(recording:).call

    render json: {}, status: :ok
  end

  # GET /meeting_ended
  # Increments a rooms recordings_processing if the meeting was recorded
  def meeting_ended
    # TODO: - ahmad: Add some sort of validation
    return render json: {} unless params[:recordingmarks] == 'true'

    @room = Room.find_by(meeting_id: extract_meeting_id)
    @room.update(recordings_processing: @room.recordings_processing + 1, online: false)

    render json: {}, status: :ok
  end

  private

  def extract_language_code(locale)
    locale.try(:scan, /^[a-z]{2}/)&.first || I18n.default_locale
  end

  def extract_meeting_id
    meeting_id = params[:meetingID]
    meeting_id = meeting_id.split('_')[0] if meeting_id.end_with?('_')
    meeting_id
  end

  def valid_invite_token(email:)
    token = cookies[:inviteToken]

    return false if token.blank?

    # Try to delete the invitation and return true if it succeeds
    Invitation.destroy_by(email:, provider: current_provider, token:).present?
  end
end
