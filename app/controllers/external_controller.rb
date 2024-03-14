# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

class ExternalController < ApplicationController
  include ClientRoutable

  skip_before_action :verify_authenticity_token

  # GET 'auth/:provider/callback'
  # Creates the user using the information received through the external auth method
  def create_user
    provider = current_provider

    credentials = request.env['omniauth.auth']
    Rails.logger.debug "External auth credentials:\r\n" + YAML::dump(credentials)

    user_info = build_user_info(credentials)

    user = User.find_by(external_id: credentials['uid'], provider:)

    # Fallback mechanism to search by email
    if user.blank?
      user = User.find_by(email: credentials['info']['email'], provider:)
      # Update the user's external id to the latest value to avoid using the fallback
      user.update(external_id: credentials['uid']) if user.present? && credentials['uid'].present?
    end

    new_user = user.blank?

    registration_method = SettingGetter.new(setting_name: 'RegistrationMethod', provider: current_provider).call

    # Check if they have a valid token only if a new sign up
    if new_user && registration_method == SiteSetting::REGISTRATION_METHODS[:invite] && !valid_invite_token(email: user_info[:email])
      return redirect_to root_path(error: Rails.configuration.custom_error_msgs[:invite_token_invalid])
    end

    # Create the user if they dont exist
    if new_user
      user = UserCreator.new(user_params: user_info, provider: current_provider, role: default_role).call
      user.save!
      create_default_room(user)

      # Send admins an email if smtp is enabled
      if ENV['SMTP_SERVER'].present?
        UserMailer.with(user:, admin_panel_url:, base_url: request.base_url,
                        provider: current_provider).new_user_signup_email.deliver_later
      end
    end

    if SettingGetter.new(setting_name: 'ResyncOnLogin', provider:).call
      user.assign_attributes(user_info.except(:language)) # Don't reset the user's language
      user.save! if user.changed?
    end

    # Set to pending if registration method is approval
    if registration_method == SiteSetting::REGISTRATION_METHODS[:approval]
      user.pending! if new_user
      return redirect_to pending_path if user.pending?
    end

    # set the cookie based on session timeout setting
    session_timeout = SettingGetter.new(setting_name: 'SessionTimeout', provider: current_provider).call
    user.generate_session_token!(extended_session: session_timeout)
    handle_session_timeout(session_timeout.to_i, user) if session_timeout

    session[:session_token] = user.session_token

    # TODO: - Ahmad: deal with errors

    redirect_location = cookies.delete(:location)

    return redirect_to redirect_location, allow_other_host: false if redirect_location&.match?('\/rooms\/\w{3}-\w{3}-\w{3}(-\w{3})?\/join\z')

    redirect_to root_path
  rescue ActionController::Redirecting::UnsafeRedirectError => e
    Rails.logger.error("Unsafe redirection attempt: #{e}")
    redirect_to root_path
  rescue StandardError => e
    Rails.logger.error("Error during authentication: #{e}")
    redirect_to root_path(error: Rails.configuration.custom_error_msgs[:external_signup_error])
  end

  # POST /recording_ready
  # Creates the recording in Greenlight using information received from BigBlueButton
  def recording_ready
    response = BigBlueButtonApi.new(provider: current_provider).decode_jwt(params[:signed_parameters])
    record_id = response[0]['record_id']
    recording = BigBlueButtonApi.new(provider: current_provider).get_recording(record_id:)

    # Only decrement if the recording doesn't already exist
    # This is needed to handle duplicate requests
    unless Recording.exists?(record_id:)
      @room = Room.find_by(meeting_id: response[0]['meeting_id'])
      @room.update(recordings_processing: @room.recordings_processing - 1) unless @room.recordings_processing.zero?
    end

    RecordingCreator.new(recording:, first_creation: true).call

    render json: {}, status: :ok
  end

  # GET /meeting_ended
  # Increments a rooms recordings_processing if the meeting was recorded
  def meeting_ended
    # TODO: - ahmad: Add some sort of validation
    @room = Room.find_by(meeting_id: extract_meeting_id)
    return render json: {}, status: :ok unless @room

    recordings_processing = params[:recordingmarks] == 'true' ? @room.recordings_processing + 1 : @room.recordings_processing

    unless @room.update(recordings_processing:, online: false)
      Rails.logger.error "Failed to update room(id): #{@room.id}, model errors: #{@room.errors}"
    end

    render json: {}, status: :ok
  end

  private

  def handle_session_timeout(session_timeout, user)
    # Creates a cookie based on session timeout site setting
    cookies.encrypted[:_extended_session] = {
      value: {
        session_token: user.session_token
      },
      expires: session_timeout.days,
      httponly: true,
      secure: true
    }
  end

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
    Invitation.destroy_by(email: email.downcase, provider: current_provider, token:).present?
  end

  def build_user_info(credentials)
    {
      name: extract_value(credentials, ENV.fetch('OPENID_CONNECT_NAME_FIELD', 'info.name')),
      email: extract_value(credentials, ENV.fetch('OPENID_CONNECT_MAIL_FIELD', 'info.email')),
      language: extract_language_code(credentials['info']['locale']),
      external_id: credentials['uid'],
      verified: true
    }
  end

  def extract_value(credentials, path)
    keys = path.split('.')
    value = credentials

    keys.each do |key|
      return nil unless value.is_a?(Hash) && value[key]
      value = value[key]
    end

    return value
  end
end
