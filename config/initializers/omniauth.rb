# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  oidc_issuer = ENV.fetch('OPENID_CONNECT_ISSUER', '')
  saml_entity = ENV.fetch('SAML_ENTITY_ID', '')
  lb = ENV.fetch('LOADBALANCER_ENDPOINT', '')

  if lb.present?
    if oidc_issuer.present?
      # OpenID Connect with LB
      provider :openid_connect, setup: lambda { |env|
        request = Rack::Request.new(env)
        current_provider = request.params['current_provider'] || request.host&.split('.')&.first
        secret = Tenant.find_by(name: current_provider)&.client_secret
        issuer_url = File.join oidc_issuer.to_s, "/#{current_provider}"

        env['omniauth.strategy'].options[:issuer] = issuer_url
        env['omniauth.strategy'].options[:scope] = %i[openid email profile]
        env['omniauth.strategy'].options[:uid_field] = ENV.fetch('OPENID_CONNECT_UID_FIELD', 'sub')
        env['omniauth.strategy'].options[:discovery] = true
        env['omniauth.strategy'].options[:client_options].identifier = ENV.fetch('OPENID_CONNECT_CLIENT_ID')
        env['omniauth.strategy'].options[:client_options].secret = secret
        env['omniauth.strategy'].options[:client_options].redirect_uri = File.join(
          File.join('https://', "#{current_provider}.#{ENV.fetch('OPENID_CONNECT_REDIRECT', '')}", 'auth', 'openid_connect', 'callback')
        )
        env['omniauth.strategy'].options[:client_options].authorization_endpoint = File.join(issuer_url, 'protocol', 'openid-connect', 'auth')
        env['omniauth.strategy'].options[:client_options].token_endpoint = File.join(issuer_url, 'protocol', 'openid-connect', 'token')
        env['omniauth.strategy'].options[:client_options].userinfo_endpoint = File.join(issuer_url, 'protocol', 'openid-connect', 'userinfo')
        env['omniauth.strategy'].options[:client_options].jwks_uri = File.join(issuer_url, 'protocol', 'openid-connect', 'certs')
        env['omniauth.strategy'].options[:client_options].end_session_endpoint = File.join(issuer_url, 'protocol', 'openid-connect', 'logout')
      }
    end
  elsif oidc_issuer.present?
    # OpenID Connect
    provider :openid_connect,
             issuer: oidc_issuer,
             scope: %i[openid email profile],
             uid_field: ENV.fetch('OPENID_CONNECT_UID_FIELD', 'sub'),
             discovery: true,
             client_options: {
               identifier: ENV.fetch('OPENID_CONNECT_CLIENT_ID'),
               secret: ENV.fetch('OPENID_CONNECT_CLIENT_SECRET'),
               redirect_uri: File.join(ENV.fetch('OPENID_CONNECT_REDIRECT', ''), 'auth', 'openid_connect', 'callback')
             }
  elsif saml_entity.present?
    # SAML
    saml_metadata_url = ENV.fetch('SAML_METADATA_URL', '')
    if saml_metadata_url.present?
      idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
      idp_metadata = idp_metadata_parser.parse_remote_to_hash(saml_metadata_url)
    else
      idp_metadata = {}
    end
    saml_fingerprint = ENV.fetch('SAML_IDP_CERT_FINGERPRINT', '')

    provider :saml,
             # Settings that are always required
             sp_entity_id: saml_entity,
             # Settings that can be derived from IDP Metadata
             idp_entity_id: idp_metadata[:idp_entity_id],
             name_identifier_format: ENV.fetch('SAML_NAME_IDENTIFIER', nil) || idp_metadata[:name_identifier_format] ||
                                     'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified',
             idp_sso_service_url: ENV.fetch('SAML_IDP_URL', nil) || idp_metadata[:idp_sso_service_url],
             idp_slo_service_url: idp_metadata[:idp_slo_service_url],
             idp_attribute_names: idp_metadata[:idp_attribute_names],
             idp_cert: saml_fingerprint.present? ? nil : idp_metadata[:cert],
             idp_cert_multi: saml_fingerprint.present? ? nil : idp_metadata[:idp_cert_multi],
             idp_cert_fingerprint: saml_fingerprint.present? ? nil : idp_metadata[:idp_cert_fingerprint],
             idp_cert_fingerprint_validator:
                 if saml_fingerprint.present?
                   ->(fp) { fp if saml_fingerprint.split(',').intersect?([fp, fp.delete(':')]) }
                 end,
             # Optional Settings
             uid_attribute: ENV.fetch('SAML_UID_ATTRIBUTE', nil),
             assertion_consumer_service_url: ENV.fetch('SAML_CALLBACK_URL', nil),
             attribute_statements: {
               email: [ENV.fetch('SAML_EMAIL_ATTRIBUTE', nil) || 'urn:mace:dir:attribute-def:mail'],
               name: [ENV.fetch('SAML_COMMONNAME_ATTRIBUTE', nil) || 'urn:mace:dir:attribute-def:cn']
             }
  end
end
