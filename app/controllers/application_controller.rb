# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Returns the current signed in User (if any)
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif cookies.signed[:user_id]
      user = User.find_by(id: cookies.signed[:user_id])
      @current_user = user if user.remember_digest == User.generate_digest(cookies[:remember_token])
    end
  end

  # Returns whether hcaptcha is enabled by checking if ENV variables are set
  def hcaptcha_enabled?
    (ENV['RECAPTCHA_SITE_KEY'].present? && ENV['RECAPTCHA_SECRET_KEY'].present?)
  end
end
