# frozen_string_literal: true

# List of supported Omniauth providers.
Rails.application.config.providers = [:google, :twitter, :microsoft_office365, :ldap]

# Set which providers are configured.
Rails.application.config.omniauth_google = ENV['GOOGLE_OAUTH2_ID'].present? && ENV['GOOGLE_OAUTH2_SECRET'].present?
Rails.application.config.omniauth_twitter = ENV['TWITTER_ID'].present? && ENV['TWITTER_SECRET'].present?
Rails.application.config.omniauth_microsoft_office365 = ENV['OFFICE365_KEY'].present? &&
                                                        ENV['OFFICE365_SECRET'].present?
Rails.application.config.omniauth_ldap = ENV['LDAP_SERVER'].present? && ENV['LDAP_UID'].present? &&
                                         ENV['LDAP_BASE'].present? && ENV['LDAP_BIND_DN'].present? &&
                                         ENV['LDAP_PASSWORD'].present?
Rails.application.config.omniauth_bn_launcher = Rails.configuration.loadbalanced_configuration

# If LDAP is enabled, override and disable allow_user_signup.
Rails.application.config.allow_user_signup = false if Rails.application.config.omniauth_ldap

SETUP_PROC = lambda do |env|
  SessionsController.helpers.omniauth_options env
end

# Setup the Omniauth middleware.
Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.configuration.omniauth_bn_launcher
    provider :bn_launcher, client_id: ENV['CLIENT_ID'],
      client_secret: ENV['CLIENT_SECRET'],
      client_options: { site: ENV['BN_LAUNCHER_REDIRECT_URI'] },
      setup: SETUP_PROC
  end

  provider :twitter, ENV['TWITTER_ID'], ENV['TWITTER_SECRET']

  provider :google_oauth2, ENV['GOOGLE_OAUTH2_ID'], ENV['GOOGLE_OAUTH2_SECRET'],
    scope: %w(profile email),
    access_type: 'online',
    name: 'google',
    hd: ENV['GOOGLE_OAUTH2_HD'].blank? ? nil : ENV['GOOGLE_OAUTH2_HD']

  provider :microsoft_office365, ENV['OFFICE365_KEY'], ENV['OFFICE365_SECRET'],
    hd: ENV['OFFICE365_HD'].blank? ? nil : ENV['OFFICE365_HD']

  provider :ldap,
    host: ENV['LDAP_SERVER'],
    port: ENV['LDAP_PORT'] || '389',
    method: ENV['LDAP_METHOD'].blank? ? :plain : ENV['LDAP_METHOD'].to_sym,
    allow_username_or_email_login: true,
    uid: ENV['LDAP_UID'],
    base: ENV['LDAP_BASE'],
    bind_dn: ENV['LDAP_BIND_DN'],
    password: ENV['LDAP_PASSWORD']
end

# Redirect back to login in development mode.
OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

# Work around beacuse callback_url option causes
# omniauth.auth to be nil in the authhash when
# authenticating with LDAP.
module OmniAuthLDAPExt
  def request_phase
    rel_root = ENV['RELATIVE_URL_ROOT'].present? ? ENV['RELATIVE_URL_ROOT'] : '/b'

    @callback_path = nil
    path = options[:callback_path]
    options[:callback_path] = "#{rel_root if Rails.env == 'production'}/auth/ldap/callback"
    form = super
    options[:callback_path] = path
    form
  end
end

module OmniAuth
  module Strategies
    class LDAP
      prepend OmniAuthLDAPExt
    end
  end
end
