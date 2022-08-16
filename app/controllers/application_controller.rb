# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

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

  # Returns the current provider value
  def current_provider
    @current_provider ||= if ENV['LOADBALANCER_ENDPOINT'].present?
                            parse_user_domain(request.host)
                          else
                            'greenlight'
                          end
  end

  private

  # Parses the url for the user domain
  def parse_user_domain(hostname)
    return hostname.split('.').first if Rails.configuration.url_host.empty?

    Rails.configuration.url_host.split(',').each do |url_host|
      return hostname.chomp(url_host).chomp('.') if hostname.include?(url_host)
    end
    ''
  end
end
