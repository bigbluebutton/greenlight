# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  issuer = ENV.fetch('OPENID_CONNECT_ISSUER', '')

  if issuer.present?
    provider :openid_connect,
             issuer:,
             scope: %i[openid email profile],
             uid_field: ENV.fetch('OPENID_CONNECT_UID_FIELD', 'preferred_username'),
             discovery: true,
             client_options: {
               identifier: ENV.fetch('OPENID_CONNECT_CLIENT_ID'),
               secret: ENV.fetch('OPENID_CONNECT_CLIENT_SECRET'),
               redirect_uri: File.join(ENV.fetch('OPENID_CONNECT_REDIRECT', ''), 'auth', 'openid_connect', 'callback')
             }
  end
end
