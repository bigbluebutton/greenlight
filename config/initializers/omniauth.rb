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
Rails.application.config.omniauth_saml = ENV['SAML_ISSUER'].present? && ENV['SAML_IDP_SSO_URL'].present? &&
                                         ENV['IDP_CERTIFICATE'].present?

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
        assertion_consumer_service_url: ENV['SAML_CALLBACK_URL'],
        issuer: ENV['SAML_ISSUER'],
        idp_sso_target_url: ENV['SAML_IDP_SSO_URL'],
        idp_slo_target_url: ENV['SAML_IDP_SLO_URL'],
        idp_cert: File.read("./cert/idp/" + ENV['IDP_CERTIFICATE']),
        # idp_cert_fingerprint: ENV['SAML_IDP_CERT_FINGERPRINT'],
        name_identifier_format: ENV['SAML_NAME_IDENTIFIER'],
        certificate: File.read("./cert/" + ENV['SP_CERTIFICATE']),
        private_key: File.read("./cert/" + ENV['SP_CERTIFICATE_PRIVATE_KEY']),
        attribute_statements: {
          nickname: [ENV['SAML_USERNAME_ATTRIBUTE'] || 'urn:mace:dir:attribute-def:eduPersonPrincipalName'],
          email: [ENV['SAML_EMAIL_ATTRIBUTE'] || 'urn:mace:dir:attribute-def:mail'],
          name: [ENV['SAML_COMMONNAME_ATTRIBUTE'] || 'urn:mace:dir:attribute-def:cn'],
          roles: [ENV['SAML_ROLES_ATTRIBUTE'] || 'urn:mace:dir:attribute-def:eduPersonAffiliation']
        },
        uid_attribute: ENV['SAML_UID_ATTRIBUTE'],
        single_logout_service_url: ENV['SINGLE_LOGOUT_SERVICE_URL'],
        soft: (ENV['SOFT_MODE'] == "true") || false,
        security: {
          authn_requests_signed: (ENV['AUTHN_REQUESTS_SIGNED'] == "true") || false,
          logout_requests_signed: ENV['LOGOUT_REQUESTS_SIGNED'] == "true" || false,
          logout_responses_signed: ENV['LOGOUT_RESPONSES_SIGNED'] == "true" || false,
          want_assertions_signed: ENV['WANT_ASSERTIONS_SIGNED'] == "true" || false,
          metadata_signed: ENV['METADATA_SIGNED'] == "true" || false,
          digest_method:  XMLSecurity::Document::SHA256,
          signature_method: XMLSecurity::Document::RSA_SHA256,
          embed_sign: ENV['EMBED_SIGN'] == "true" || false,
          check_idp_cert_expiration: ENV['CHECK_IDP_CERT_EXPIRATION'] == "true" || false,
          check_sp_cert_expiration: ENV['CHECK_SP_CERT_EXPIRATION'] == "true" || false
        }
    end
  end
end

# Redirect back to login in development mode.
OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
