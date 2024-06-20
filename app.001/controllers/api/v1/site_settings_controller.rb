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
    class SiteSettingsController < ApiController
      skip_before_action :ensure_authenticated, only: :index
      FORBIDDEN_SETTINGS = %w[RoleMapping ResyncOnLogin DefaultRole].freeze # Should not be accessible to the frontend

      # GET /api/v1/site_settings
      # Returns the values of 1 or multiple site_settings that are not forbidden to access
      def index
        return render_error status: :forbidden if forbidden_settings(params[:names])

        settings = SettingGetter.new(setting_name: params[:names], provider: current_provider).call

        render_data data: settings, status: :ok
      end

      private

      # Prevents front-end from accessing sensitive site settings
      def forbidden_settings(names)
        # Check if the 2 arrays have any values in common
        !!Array(names).intersect?(FORBIDDEN_SETTINGS)
      end
    end
  end
end
