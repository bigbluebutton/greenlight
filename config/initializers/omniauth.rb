# frozen_string_literal: true

require 'office365'

# List of supported Omniauth providers.
Rails.application.config.providers = []

# Set which providers are configured.
Rails.application.config.omniauth_bn_launcher = Rails.configuration.loadbalanced_configuration
Rails.application.config.omniauth_ldap = ENV['LDAP_SERVER'].present? && ENV['LDAP_UID'].present? &&
                                         ENV['LDAP_BASE'].present? && ENV['LDAP_BIND_DN'].present? &&
                                         ENV['LDAP_PASSWORD'].present?
Rails.application.config.omniauth_twitter = ENV['TWITTER_ID'].present? && ENV['TWITTER_SECRET'].present?
Rails.application.config.omniauth_google = ENV['GOOGLE_OAUTH2_ID'].present? && ENV['GOOGLE_OAUTH2_SECRET'].present?
Rails.application.config.omniauth_office365 = ENV['OFFICE365_KEY'].present? &&
                                              ENV['OFFICE365_SECRET'].present?

SETUP_PROC = lambda do |env|
  SessionsController.helpers.omniauth_options env
end

# Setup the Omniauth middleware.
Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.configuration.omniauth_bn_launcher
    provider :bn_launcher, client_id: ENV['CLIENT_ID'],
      client_secret: ENV['CLIENT_SECRET'],
      client_options: { site: ENV['BN_LAUNCHER_URI'] || ENV['BN_LAUNCHER_REDIRECT_URI'] },
      setup: SETUP_PROC
  else
    Rails.application.config.providers << :ldap if Rails.configuration.omniauth_ldap

    if Rails.configuration.omniauth_twitter
      Rails.application.config.providers << :twitter

      provider :twitter, ENV['TWITTER_ID'], ENV['TWITTER_SECRET']
    end
    if Rails.configuration.omniauth_google
      Rails.application.config.providers << :google

      provider :google_oauth2, ENV['GOOGLE_OAUTH2_ID'], ENV['GOOGLE_OAUTH2_SECRET'],
        scope: %w(profile email),
        access_type: 'online',
        name: 'google',
        setup: SETUP_PROC
    end
    if Rails.configuration.omniauth_office365
      Rails.application.config.providers << :office365

      provider :office365, ENV['OFFICE365_KEY'], ENV['OFFICE365_SECRET'],
      setup: SETUP_PROC
    end
  end
end

# Redirect back to login in development mode.
OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
