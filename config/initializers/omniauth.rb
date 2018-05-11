# List of supported Omniauth providers.
Rails.application.config.providers = [:google, :twitter]

# Set which providers are configured.
Rails.application.config.omniauth_google = ENV['GOOGLE_OAUTH2_ID'].present? && ENV['GOOGLE_OAUTH2_SECRET'].present?
Rails.application.config.omniauth_twitter = ENV['TWITTER_ID'].present? && ENV['TWITTER_SECRET'].present?

# Setup the Omniauth middleware.
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_ID'], ENV['TWITTER_SECRET']

  provider :google_oauth2, ENV['GOOGLE_OAUTH2_ID'], ENV['GOOGLE_OAUTH2_SECRET'],
    scope: ['profile', 'email'],
    access_type: 'online',
    name: 'google',
    hd: ENV['GOOGLE_OAUTH2_HD'].blank? ? nil : ENV['GOOGLE_OAUTH2_HD']
end