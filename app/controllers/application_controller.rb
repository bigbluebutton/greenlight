# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Returns the current signed in User (if any)
  def current_user
    # Overwrites the session cookie if an extended_session cookie exists
    session[:user_id] ||= cookies.encrypted[:_extended_session]['user_id'] if cookies.encrypted[:_extended_session].present?
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # Returns whether hcaptcha is enabled by checking if ENV variables are set
  def hcaptcha_enabled?
    (ENV['HCAPTCHA_SITE_KEY'].present? && ENV['HCAPTCHA_SECRET_KEY'].present?)
  end
end
