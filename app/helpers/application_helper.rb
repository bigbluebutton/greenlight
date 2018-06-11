module ApplicationHelper
  include MeetingsHelper

  # Gets all configured omniauth providers.
  def configured_providers
    Rails.configuration.providers.select do |provider|
      Rails.configuration.send("omniauth_#{provider}")
    end
  end

  # Generates the login URL for a specific provider.
  def omniauth_login_url(provider)
    "/auth/#{provider}"
  end
  
  # Determine if Greenlight is configured to allow user signups.
  def allow_user_signup?
    Rails.configuration.allow_user_signup
  end

  def bigbluebutton_endpoint_default?
    Rails.configuration.bigbluebutton_endpoint_default == Rails.configuration.bigbluebutton_endpoint
  end
end
