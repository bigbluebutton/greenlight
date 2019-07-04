# frozen_string_literal: true

require 'azure_ad'

# List of supported Omniauth providers.
Rails.application.config.providers = []

# Set which providers are configured.
Rails.application.config.omniauth_ldap = ENV['LDAP_SERVER'].present? && ENV['LDAP_UID'].present? &&
                                         ENV['LDAP_BASE'].present? && ENV['LDAP_BIND_DN'].present? &&
                                         ENV['LDAP_PASSWORD'].present?
Rails.application.config.omniauth_twitter = ENV['TWITTER_ID'].present? && ENV['TWITTER_SECRET'].present?
Rails.application.config.omniauth_google = ENV['GOOGLE_OAUTH2_ID'].present? && ENV['GOOGLE_OAUTH2_SECRET'].present?
Rails.application.config.omniauth_office365 = ENV['OFFICE365_KEY'].present? &&
                                              ENV['OFFICE365_SECRET'].present?
Rails.application.config.omniauth_saml = ENV['SAML_ISSUER'].present? &&
                                         ENV['SAML_TARGET_URL'].present? &&
                                         ENV['SAML_FINGERPRINT'].present?

SETUP_PROC = lambda do |env|
  env['omniauth.strategy'].options[:request_attributes] = [
    {
      name: 'email',
      is_required: "true",
      friendly_name: 'email',
      name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
    },
    {
      name: 'user_id',
      is_required: "true",
      friendly_name: 'username',
      name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
    },
    {
      name: 'name',
      is_required: "true",
      friendly_name: 'name',
      name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
    },
    {
      name: 'image',
      is_required: "false",
      friendly_name: 'profile picture',
      name_format: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
    }
  ]
  SessionsController.helpers.omniauth_options env
end

# Setup the Omniauth middleware.
Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.configuration.loadbalanced_configuration || Rails.configuration.omniauth_ldap
    Rails.application.config.providers << :ldap
  end
  provider :saml, setup: SETUP_PROC if Rails.configuration.loadbalanced_configuration
  if Rails.configuration.omniauth_saml && !Rails.configuration.loadbalanced_configuration
    Rails.application.config.providers << :saml

    provider :saml,
    issuer: ENV['SAML_ISSUER'],
    idp_sso_target_url: ENV['SAML_TARGET_URL'],
    idp_cert_fingerprint: ENV['SAML_FINGERPRINT']
  end
  if Rails.configuration.omniauth_twitter
    Rails.application.config.providers << :twitter

    provider :twitter, ENV['TWITTER_ID'], ENV['TWITTER_SECRET']
  end
  if Rails.configuration.omniauth_google
    Rails.application.config.providers << :google

    scope = if ENV['ENABLE_YOUTUBE_UPLOADING'] && ENV['ENABLE_YOUTUBE_UPLOADING'] == 'true'
              ['profile', 'email', 'youtube', 'youtube.upload']
            else
              %w(profile email)
            end

    provider :google_oauth2, ENV['GOOGLE_OAUTH2_ID'], ENV['GOOGLE_OAUTH2_SECRET'],
      scope: scope,
      access_type: 'online',
      name: 'google',
      setup: SETUP_PROC
  end
  if Rails.configuration.omniauth_office365
    Rails.application.config.providers << :office365

    provider :azure_ad, ENV['OFFICE365_KEY'], ENV['OFFICE365_SECRET'],
              name: 'office365',
              setup: SETUP_PROC
  end
end

# Redirect back to login in development mode.
OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
