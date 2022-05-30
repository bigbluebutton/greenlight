require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer

  provider :openid_connect,
    issuer: ENV["OPENID_CONNECT_ISSUER"],
    scope: [:openid, :email, :profile],
    uid_field: ENV["OPENID_CONNECT_UID_FIELD"] || "preferred_username",
    discovery: true,
    client_options: {
      identifier: ENV['OPENID_CONNECT_CLIENT_ID'],
      secret: ENV['OPENID_CONNECT_CLIENT_SECRET'],
      redirect_uri: File.join(ENV['OPENID_CONNECT_REDIRECT'], "auth", "openid_connect", "callback")
    }
end