module ApplicationHelper

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
end
