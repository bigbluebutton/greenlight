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
      class ServerRoomsController < ApiController
        before_action do
          ensure_authorized('ManageRooms')
        end

        before_action :find_room, only: %i[resync]

        # GET /api/v1/admin/server_rooms.json
        # Fetches a list of all server rooms
        def index
          sort_config = config_sorting(allowed_columns: %w[name users.name])

          rooms = Room.includes(:user).where(users: { provider: current_provider }).order(sort_config, online: :desc)
                      .order('last_session DESC NULLS LAST')&.admin_search(params[:search])

          pagy, paged_rooms = pagy(rooms)

          RunningMeetingChecker.new(rooms: paged_rooms.select(&:online)).call if paged_rooms.any?(&:online)

          render_data data: paged_rooms, meta: pagy_metadata(pagy), serializer: ServerRoomSerializer, status: :ok
        end

        # GET /api/v1/admin/server_rooms/:friendly_id/resync.json
        # Re-syncs a room recordings.
        def resync
          RecordingsSync.new(room: @room, provider: current_provider).call

          render_data status: :ok
        end

        private

        def find_room
          @room = Room.find_by!(friendly_id: params[:friendly_id])
        end
      end
    end
  end
end
