# frozen_string_literal: true

class ExternalController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :recording_ready

  # GET 'auth/:provider/callback'
  def create_user
    credentials = request.env['omniauth.auth']
    user_info = credentials['info']
    user = User.find_or_create_by(email: user_info['email']) do |u|
      u.external_id = credentials['uid']
      u.name = user_info['name']
      u.provider = 'greenlight'
      u.role = Role.find_by(name: 'User') # TODO: - Ahmad: Move to service
      u.language = extract_language_code user_info['locale']
    end

    session[:user_id] = user.id

    # TODO: - Ahmad: deal with errors

    redirect_to '/rooms'
  end

  # POST /recording_ready
  def recording_ready
    BigBlueButtonApi.new.decode_jwt(params[:signed_parameters])
    render json, status: :ok
  end

  # GET /meeting_ended
  def meeting_ended
    render json, status: :ok
  end

  private

  def extract_language_code(locale)
    locale.try(:scan, /^[a-z]{2}/)&.first || I18n.default_locale
  end
end
