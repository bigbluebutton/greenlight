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

module Api
  module V1
    class EnvController < ApiController
      skip_before_action :ensure_authenticated

      # GET /api/v1/env
      # Returns basic NON-CONFIDENTIAL information on the environment variables
      def index
        render_data data: {
          EXTERNAL_AUTH: ENV['OPENID_CONNECT_ISSUER'].present?, # currently only OIDC is implemented
          HCAPTCHA_KEY: ENV.fetch('HCAPTCHA_SITE_KEY', nil),
          VERSION_TAG: ENV.fetch('VERSION_TAG', ''),
          CURRENT_PROVIDER: current_provider,
          SMTP_ENABLED: ENV.fetch('SMTP_SERVER', nil)
        }, status: :ok
      end
    end
  end
end
