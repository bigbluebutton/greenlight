# frozen_string_literal: true

# List of supported Omniauth providers.
Rails.application.config.providers = [:google, :twitter, :bn_launcher]

# Set which providers are configured.
Rails.application.config.omniauth_google = ENV['GOOGLE_OAUTH2_ID'].present? && ENV['GOOGLE_OAUTH2_SECRET'].present?
Rails.application.config.omniauth_twitter = ENV['TWITTER_ID'].present? && ENV['TWITTER_SECRET'].present?
Rails.application.config.omniauth_bn_launcher = (ENV["USE_LOADBALANCED_CONFIGURATION"] == "true")

# Setup the Omniauth middleware.
Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?
    provider :bn_launcher,
             client_id: ENV['CLIENT_ID'],
             client_secret: ENV['CLIENT_SECRET'],
             client_options: {site: ENV['BN_LAUNCHER_REDIRECT_URI']}
  end


  provider :twitter, ENV['TWITTER_ID'], ENV['TWITTER_SECRET']

  provider :google_oauth2, ENV['GOOGLE_OAUTH2_ID'], ENV['GOOGLE_OAUTH2_SECRET'],
    scope: %w(profile email),
    access_type: 'online',
    name: 'google',
    hd: ENV['GOOGLE_OAUTH2_HD'].blank? ? nil : ENV['GOOGLE_OAUTH2_HD']
end
