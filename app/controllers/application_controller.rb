# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Returns the current signed in User (if any)
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def render_json(data: {}, errors: [], status: :ok, include: nil)
    render json: {
      data:,
      errors:
    }, status:, include:
  end

  # Returns whether hcaptcha is enabled by checking if ENV variables are set
  def hcaptcha_enabled?
    (ENV['RECAPTCHA_SITE_KEY'].present? && ENV['RECAPTCHA_SECRET_KEY'].present?)
  end
end
