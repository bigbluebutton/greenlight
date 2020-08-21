# frozen_string_literal: true

require 'office365'
require 'omniauth_options'

include OmniauthOptions

# List of supported Omniauth providers.
Rails.application.config.providers = []

# Set which providers are configured.
Rails.application.config.omniauth_bn_launcher = Rails.configuration.loadbalanced_configuration
Rails.application.config.omniauth_ldap = ENV['LDAP_SERVER'].present? && ENV['LDAP_UID'].present? &&
                                         ENV['LDAP_BASE'].present?
Rails.application.config.omniauth_twitter = ENV['TWITTER_ID'].present? && ENV['TWITTER_SECRET'].present?
Rails.application.config.omniauth_google = ENV['GOOGLE_OAUTH2_ID'].present? && ENV['GOOGLE_OAUTH2_SECRET'].present?
Rails.application.config.omniauth_office365 = ENV['OFFICE365_KEY'].present? &&
                                              ENV['OFFICE365_SECRET'].present?
Rails.application.config.omniauth_saml = ENV['SAML_ISSUER'].present? && ENV['SAML_IDP_URL'].present? &&
                                         ENV['SAML_IDP_CERT_FINGERPRINT'].present?

SETUP_PROC = lambda do |env|
  OmniauthOptions.omniauth_options env
end

OmniAuth.config.logger = Rails.logger

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

      redirect = ENV['OAUTH2_REDIRECT'].present? ? File.join(ENV['OAUTH2_REDIRECT'], "auth", "google", "callback") : nil

      provider :google_oauth2, ENV['GOOGLE_OAUTH2_ID'], ENV['GOOGLE_OAUTH2_SECRET'],
        scope: %w(profile email),
        access_type: 'online',
        name: 'google',
        redirect_uri: redirect,
        setup: SETUP_PROC
    end
    if Rails.configuration.omniauth_office365
      Rails.application.config.providers << :office365

      redirect = ENV['OAUTH2_REDIRECT'].present? ? File.join(ENV['OAUTH2_REDIRECT'], "auth", "office365", "callback") : nil

      provider :office365, ENV['OFFICE365_KEY'], ENV['OFFICE365_SECRET'],
      redirect_uri: redirect,
      setup: SETUP_PROC
    end
    if Rails.configuration.omniauth_saml
      Rails.application.config.providers << :saml

      provider :saml,
        issuer: ENV['SAML_ISSUER'],
        idp_sso_target_url: ENV['SAML_IDP_URL'],
        idp_cert_fingerprint: ENV['SAML_IDP_CERT_FINGERPRINT'],
        name_identifier_format: ENV['SAML_NAME_IDENTIFIER'],
        attribute_statements: {
          nickname: [ENV['SAML_USERNAME_ATTRIBUTE'] || 'urn:mace:dir:attribute-def:eduPersonPrincipalName'],
          email: [ENV['SAML_EMAIL_ATTRIBUTE'] || 'urn:mace:dir:attribute-def:mail'],
          name: [ENV['SAML_COMMONNAME_ATTRIBUTE'] || 'urn:mace:dir:attribute-def:cn']
        },
        uid_attribute: ENV['SAML_UID_ATTRIBUTE']
    end
  end
end

# Redirect back to login in development mode.
OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
