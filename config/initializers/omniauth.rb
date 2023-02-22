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
