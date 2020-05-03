# frozen_string_literal: true

require 'jwt'
require 'uri'
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
Rails.application.config.omniauth_apple = ENV['APPLE_CLIENT_ID'].present? &&
                                          ENV['APPLE_TEAM_ID'].present? &&
                                          ENV['APPLE_KEY_ID'].present? &&
                                          ENV['APPLE_PRIVATE_KEY'].present?
Rails.application.config.omniauth_facebook = ENV['FACEBOOK_CLIENT_ID'].present? &&
                                             ENV['FACEBOOK_CLIENT_SECRET'].present?
Rails.application.config.omniauth_github = ENV['GITHUB_CLIENT_ID'].present? &&
                                           ENV['GITHUB_CLIENT_SECRET'].present?
Rails.application.config.omniauth_instagram = ENV['INSTAGRAM_CLIENT_ID'].present? &&
                                              ENV['INSTAGRAM_CLIENT_SECRET'].present?
Rails.application.config.omniauth_linkedin = ENV['LINKEDIN_CLIENT_ID'].present? &&
                                             ENV['LINKEDIN_CLIENT_SECRET'].present?
Rails.application.config.omniauth_openid_connect = ENV['OPENID_CONNECT_CLIENT_ID'].present? &&
                                                   ENV['OPENID_CONNECT_CLIENT_SECRET'].present? &&
                                                   ENV['OPENID_CONNECT_ISSUER'].present?

SETUP_PROC = lambda do |env|
  env['omniauth.strategy'].options[:client_options][:redirect_uri] ||=
    (env['omniauth.strategy'].full_host + env['omniauth.strategy'].script_name + env['omniauth.strategy'].callback_path)
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

      redirect = ENV['OAUTH2_REDIRECT'].present? ? File.join(ENV['OAUTH2_REDIRECT'], 'auth', 'google', 'callback') : nil

      provider :openid_connect,
               name: :google,
               issuer: 'https://accounts.google.com',
               discovery: true,
               scope: [:openid, :email, :profile],
               response_type: :code,
               client_options: {
                 identifier: ENV['GOOGLE_OAUTH2_ID'],
                 secret: ENV['GOOGLE_OAUTH2_SECRET'],
                 redirect_uri: redirect
               },
               setup: SETUP_PROC
    end
    if Rails.configuration.omniauth_office365
      Rails.application.config.providers << :office365

      redirect = ENV['OAUTH2_REDIRECT'].present? ? File.join(ENV['OAUTH2_REDIRECT'], 'auth', 'office365', 'callback') : nil

      provider :openid_connect,
               name: :office365,
               issuer: 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize',
               scope: [:openid, :email, :profile],
               response_type: :code,
               client_options: {
                 host: 'login.microsoftonline.com',
                 authorization_endpoint: '/common/oauth2/v2.0/authorize',
                 token_endpoint: '/common/oauth2/v2.0/token',
                 identifier: ENV['OFFICE365_KEY'],
                 secret: ENV['OFFICE365_SECRET'],
                 redirect_uri: redirect
               },
               setup: SETUP_PROC
    end
    if Rails.configuration.omniauth_apple
      Rails.application.config.providers << :apple

      redirect = ENV['OAUTH2_REDIRECT'].present? ? File.join(ENV['OAUTH2_REDIRECT'], 'auth', 'apple', 'callback') : nil

      ecdsa_key = OpenSSL::PKey::EC.new ENV['APPLE_PRIVATE_KEY']

      headers = {
        'kid' => ENV['APPLE_KEY_ID']
      }

      claims = {
        'iss' => ENV['APPLE_TEAM_ID'],
        'iat' => Time.now.to_i,
        'exp' => Time.now.to_i + 300, # expires in 5 minutes
        'aud' => 'https://appleid.apple.com',
        'sub' => ENV['APPLE_CLIENT_ID'],
      }

      token = JWT.encode claims, ecdsa_key, 'ES256', headers

      provider :openid_connect,
               name: :apple,
               issuer: 'https://appleid.apple.com/auth/authorize',
               scope: [:openid, :email, :profile],
               response_type: :code,
               client_options: {
                 host: 'appleid.apple.com',
                 authorization_endpoint: '/auth/authorize',
                 token_endpoint: '/auth/token',
                 identifier: ENV['APPLE_CLIENT_ID'],
                 secret: token,
                 redirect_uri: redirect
               },
               setup: SETUP_PROC
    end
    if Rails.configuration.omniauth_facebook
      Rails.application.config.providers << :facebook

      redirect = ENV['OAUTH2_REDIRECT'].present? ? File.join(ENV['OAUTH2_REDIRECT'], 'auth', 'facebook', 'callback') : nil

      provider :openid_connect,
               name: :facebook,
               issuer: 'https://www.facebook.com/v6.0/dialog/oauth',
               discovery: true,
               scope: [:openid, :email, :profile],
               response_type: :code,
               client_options: {
                 identifier: ENV['FACEBOOK_CLIENT_ID'],
                 secret: ENV['FACEBOOK_CLIENT_SECRET'],
                 redirect_uri: redirect
               },
               setup: SETUP_PROC
    end
    if Rails.configuration.omniauth_github
      Rails.application.config.providers << :github

      redirect = ENV['OAUTH2_REDIRECT'].present? ? File.join(ENV['OAUTH2_REDIRECT'], 'auth', 'github', 'callback') : nil

      provider :openid_connect,
               name: :github,
               issuer: 'https://github.com/login/oauth/authorize',
               scope: [:openid, :email, :profile],
               response_type: :code,
               client_options: {
                 host: 'github.com',
                 authorization_endpoint: '/login/oauth/authorize',
                 token_endpoint: '/login/oauth/access_token',
                 identifier: ENV['GITHUB_CLIENT_ID'],
                 secret: ENV['GITHUB_CLIENT_SECRET'],
                 redirect_uri: redirect
               },
               setup: SETUP_PROC
    end
    if Rails.configuration.omniauth_instagram
      Rails.application.config.providers << :instagram

      redirect = ENV['OAUTH2_REDIRECT'].present? ? File.join(ENV['OAUTH2_REDIRECT'], 'auth', 'instagram', 'callback') : nil

      provider :openid_connect,
               name: :instagram,
               issuer: 'https://api.instagram.com/oauth/authorize',
               scope: [:openid, :email, :profile],
               response_type: :code,
               client_options: {
                 host: 'api.instagram.com',
                 authorization_endpoint: '/oauth/authorize',
                 token_endpoint: '/oauth/access_token',
                 identifier: ENV['INSTAGRAM_CLIENT_ID'],
                 secret: ENV['INSTAGRAM_CLIENT_SECRET'],
                 redirect_uri: redirect
               },
               setup: SETUP_PROC
    end
    if Rails.configuration.omniauth_linkedin
      Rails.application.config.providers << :linkedin

      redirect = ENV['OAUTH2_REDIRECT'].present? ? File.join(ENV['OAUTH2_REDIRECT'], 'auth', 'linkedin', 'callback') : nil

      provider :openid_connect,
               name: :linkedin,
               issuer: 'https://www.linkedin.com/oauth/v2/authorization',
               scope: [:openid, :email, :profile],
               response_type: :code,
               client_options: {
                 host: 'www.linkedin.com',
                 authorization_endpoint: '/oauth/v2/authorization',
                 token_endpoint: '/oauth/v2/accessToken',
                 identifier: ENV['LINKEDIN_CLIENT_ID'],
                 secret: ENV['LINKEDIN_CLIENT_SECRET'],
                 redirect_uri: redirect
               },
               setup: SETUP_PROC
    end
    if Rails.configuration.omniauth_openid_connect
      Rails.application.config.providers << :openid_connect

      redirect = ENV['OAUTH2_REDIRECT'].present? ? File.join(ENV['OAUTH2_REDIRECT'], 'auth', 'openid_connect', 'callback') : nil

      uri = URI(ENV['OPENID_CONNECT_SITE'].present? ? ENV['OPENID_CONNECT_SITE'] : '')

      client_options = {
        identifier: ENV['OPENID_CONNECT_CLIENT_ID'],
        secret: ENV['OPENID_CONNECT_CLIENT_SECRET'],
        redirect_uri: redirect,
        scheme: uri.scheme,
        host: uri.host,
        port: uri.port
      }.compact

      {
        authorization_endpoint: 'OPENID_CONNECT_AUTHORIZATION_ENDPOINT',
        token_endpoint: 'OPENID_CONNECT_TOKEN_ENDPOINT',
        end_session_endpoint: 'OPENID_CONNECT_END_SESSION_ENDPOINT'
      }.each { |key, value| client_options[key] = ENV[value] if ENV[value].present? }

      provider :openid_connect,
               name: :openid_connect,
               issuer: ENV['OPENID_CONNECT_ISSUER'],
               discovery: !(ENV['OPENID_CONNECT_DISCOVERY'].present? && ENV['OPENID_CONNECT_DISCOVERY'] == 'false'),
               scope: [:openid, :email, :profile],
               response_type: :code,
               uid_field: ENV['OPENID_CONNECT_UID_FIELD'].present? ? ENV['OPENID_CONNECT_UID_FIELD'] : 'sub',
               client_options: client_options,
               setup: SETUP_PROC
    end
  end
end

# Redirect back to login in development mode.
OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
