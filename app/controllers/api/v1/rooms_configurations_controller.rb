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
    class RoomsConfigurationsController < ApiController
      before_action only: %i[index] do
        ensure_authorized(%w[CreateRoom ManageSiteSettings ManageRoles ManageRooms], friendly_id: params[:friendly_id])
      end

      # GET /api/v1/rooms_configurations.json
      # Fetches and returns all rooms configurations.
      def index
        rooms_configs = MeetingOption.joins(:rooms_configurations)
                                     .where(rooms_configurations: { provider: current_provider })
                                     .pluck(:name, :value)
                                     .to_h

        render_data data: rooms_configs, status: :ok
      end
    end
  end
end
