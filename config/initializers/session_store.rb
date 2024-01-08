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

if ENV['LOADBALANCER_ENDPOINT'].present?
  Rails.application.config.session_store :cookie_store, key: '_greenlight-3_0_session', domain: ENV.fetch('SESSION_DOMAIN_NAME', nil),
                                                        path: ENV.fetch('RELATIVE_URL_ROOT', '/')
else
  Rails.application.config.session_store :cookie_store, key: '_greenlight-3_0_session', path: ENV.fetch('RELATIVE_URL_ROOT', '/')
end
