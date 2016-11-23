Rails.application.config.providers = [:google, :twitter]

Rails.application.config.omniauth_google = ENV['GOOGLE_OAUTH2_ID'].present?

Rails.application.config.omniauth_twitter = ENV['TWITTER_ID'].present?

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_ID'], ENV['TWITTER_SECRET']
  provider :google_oauth2, ENV['GOOGLE_OAUTH2_ID'], ENV['GOOGLE_OAUTH2_SECRET'],
    scope: ['profile', 'email'], access_type: 'online', name: 'google'
end
