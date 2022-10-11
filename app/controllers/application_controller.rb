# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Returns the current signed in User (if any)
  def current_user
    # Overwrites the session cookie if an extended_session cookie exists
    session[:session_token] ||= cookies.encrypted[:_extended_session]['session_token'] if cookies.encrypted[:_extended_session].present?

    user = User.find_by(session_token: session[:session_token])

    if user && invalid_session?(user)
      session[:session_token] = nil
      cookies.delete :_extended_session
      return nil
    end

    @current_user ||= user
  end

  # Returns whether hcaptcha is enabled by checking if ENV variables are set
  def hcaptcha_enabled?
    (ENV['HCAPTCHA_SITE_KEY'].present? && ENV['HCAPTCHA_SECRET_KEY'].present?)
  end

  # Returns the current provider value
  def current_provider
    @current_provider ||= if ENV['LOADBALANCER_ENDPOINT'].present?
                            parse_user_domain(request.host)
                          else
                            'greenlight'
                          end
  end

  # Returns the default role
  def default_role
    default_role_setting = SettingGetter.new(setting_name: 'DefaultRole', provider: current_provider).call
    @default_role = Role.find_by(name: default_role_setting, provider: current_provider)
  end

  private

  # Checks if the user's session_token matches the session and that it is not expired
  def invalid_session?(user)
    return true if user&.session_token != session[:session_token]
    return true if user&.session_expiry && DateTime.now > user&.session_expiry

    false
  end

  # Parses the url for the user domain
  def parse_user_domain(hostname)
    return hostname.split('.').first if Rails.configuration.url_host.empty?

    Rails.configuration.url_host.split(',').each do |url_host|
      return hostname.chomp(url_host).chomp('.') if hostname.include?(url_host)
    end
    ''
  end
end
