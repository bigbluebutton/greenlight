Rails.application.config.providers = [:google, :twitter, :ldap, :saml]

Rails.application.config.omniauth_google = ENV['GOOGLE_OAUTH2_ID'].present? && ENV['GOOGLE_OAUTH2_SECRET'].present?

Rails.application.config.omniauth_twitter = ENV['TWITTER_ID'].present? && ENV['TWITTER_SECRET'].present?

Rails.application.config.omniauth_ldap = ENV['LDAP_SERVER'].present? && ENV['LDAP_UID'].present? && ENV['LDAP_BASE'].present? && ENV['LDAP_BIND_DN'].present? && ENV['LDAP_PASSWORD'].present?

Rails.application.config.omniauth_saml = ENV['SAML_ISSUER'].present? && ENV['SAML_IDP_URL'].present? && ENV['SAML_IDP_CERT_FINGERPRINT'].present?

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_ID'], ENV['TWITTER_SECRET']
  provider :google_oauth2, ENV['GOOGLE_OAUTH2_ID'], ENV['GOOGLE_OAUTH2_SECRET'],
    scope: ENV['ENABLE_YOUTUBE_UPLOADING'] && ENV['ENABLE_YOUTUBE_UPLOADING'] == "true" ? ['profile', 'email', 'youtube', 'youtube.upload'] : ['profile', 'email'] ,
    access_type: 'online',
    name: 'google',
    hd: ENV['GOOGLE_OAUTH2_HD']
  provider :ldap,
    host: ENV['LDAP_SERVER'],
    port: ENV['LDAP_PORT'] || '389',
    method: (ENV['LDAP_METHOD'] || 'plain').to_sym,
    allow_username_or_email_login: true,
    uid: ENV['LDAP_UID'],
    base: ENV['LDAP_BASE'],
    bind_dn: ENV['LDAP_BIND_DN'],
    password: ENV['LDAP_PASSWORD']
  provider :saml,
    issuer: ENV['SAML_ISSUER'],
    idp_sso_target_url: ENV['SAML_IDP_URL'],
    idp_cert_fingerprint: ENV['SAML_IDP_CERT_FINGERPRINT'],
    name_identifier_format: ENV['SAML_NAME_IDENTIFIER'] || "urn:mace:dir:attribute-def:eduPersonPrincipalName",
    attribute_statements: { \
    	nickname:	[ENV['SAML_USERNAME_ATTRIBUTE'] || 'urn:mace:dir:attribute-def:eduPersonPrincipalName'],\
    	email:		[ENV['SAML_EMAIL_ATTRIBUTE'] || 'urn:mace:dir:attribute-def:mail'], \
    	last_name:	[ENV['SAML_LASTNAME_ATTRIBUTE'] || 'urn:mace:dir:attribute-def:sn'], \
    	first_name:	[ENV['SAML_FIRTSNAME_ATTRIBUTE'] || 'urn:mace:dir:attribute-def:givenName'],\
    	name:		[ENV['SAML_COMMOMNAME_ATTRIBUTE'] || 'urn:mace:dir:attribute-def:cn'] },
    uid_attribute: ENV['SAML_UID_ATTRIBUTE'] || "urn:mace:dir:attribute-def:uid"
end

# Redirect back to login in development mode.
OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

# Work around beacuse callback_url option causes
# omniauth.auth to be nil in the authhash when
# authenticating with LDAP.

module OmniAuthLDAPExt
    def request_phase

        rel_root = ENV['RELATIVE_URL_ROOT'].present? ? ENV['RELATIVE_URL_ROOT'] : '/b'
        rel_root = '' if Rails.env == 'development'

        @callback_path = nil
        path = options[:callback_path]
        options[:callback_path] = "#{rel_root}/auth/ldap/callback"
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
