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
    module Admin
      class RoomsConfigurationsController < ApiController
        before_action do
          ensure_authorized('ManageSiteSettings')
        end

        # PUT /api/v1/admin/rooms_configurations/:name.json
        # Update a rooms configuration value
        def update
          return render_error status: :bad_request unless params[:RoomsConfig] && params[:RoomsConfig][:value]

          rooms_config = RoomsConfiguration.joins(:meeting_option)
                                           .find_by(
                                             provider: current_provider,
                                             meeting_option: { name: params[:name] }
                                           )

          return render_error status: :not_found unless rooms_config

          return render_error status: :bad_request unless rooms_config.update(value: params[:RoomsConfig][:value])

          render_data status: :ok
        end
      end
    end
  end
end
