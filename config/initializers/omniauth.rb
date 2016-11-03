Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_ID'], ENV['TWITTER_SECRET']
  provider :google_oauth2, ENV['GOOGLE_OAUTH2_ID'], ENV['GOOGLE_OAUTH2_SECRET'],
    scope: ['profile'], access_type: 'online', name: 'google'
end
