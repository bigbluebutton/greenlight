# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

module LdapAuthenticator
    extend ActiveSupport::Concern

    def send_ldap_request(session_params)
        host = ''
        port = 389
        bind_dn = ''
        password = ''
        encryption = nil
        base = ''
        uid = ''

        if Rails.configuration.loadbalanced_configuration
          customer = parse_user_domain(request.host)
          customer_info = retrieve_provider_info(customer, 'api2', 'getUserGreenlightCredentials')

          host = customer_info['LDAP_SERVER']
          port = customer_info['LDAP_PORT'].to_i != 0 ? customer_info['LDAP_PORT'].to_i : 389
          bind_dn = customer_info['LDAP_BIND_DN']
          password = customer_info['LDAP_PASSWORD']
          encryption = config.ldap_encryption = if customer_info['LDAP_METHOD'] == 'ssl'
                                                  'simple_tls'
                                                elsif customer_info['LDAP_METHOD'] == 'tls'
                                                  'start_tls'
                                                end
          base = customer_info['LDAP_BASE']
          uid = customer_info['LDAP_UID']
        else
          host = Rails.configuration.ldap_host
          port = Rails.configuration.ldap_port
          bind_dn = Rails.configuration.ldap_bind_dn
          password = Rails.configuration.ldap_password
          encryption = Rails.configuration.ldap_encryption
          base = Rails.configuration.ldap_base
          uid = Rails.configuration.ldap_uid
        end

        ldap = Net::LDAP.new(
          host: host,
          port: port,
          auth: {
            method: :simple,
            username: bind_dn,
            password: password
          },
          encryption: encryption
        )

        ldap.bind_as(
          base: base,
          filter: "(#{uid}=#{session_params[:password]})",
          password: session_params[:password]
        )
    end
end
