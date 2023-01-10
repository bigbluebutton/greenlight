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
        def index
          sort_config = config_sorting(allowed_columns: %w[name users.name])

          rooms = Room.includes(:user).joins(:user).where(users: { provider: current_provider }).order(sort_config, online: :desc)
                      .order('last_session DESC NULLS LAST')&.admin_search(params[:search])

          online_server_rooms(rooms)

          pagy, rooms = pagy_array(rooms)

          render_data data: rooms, meta: pagy_metadata(pagy), serializer: ServerRoomSerializer, status: :ok
        end

        # GET /api/v1/admin/server_rooms/:friendly_id/resync.json
        # Expects: {}
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Re-syncs a room recordings.
        def resync
          RecordingsSync.new(room: @room).call

          render_data status: :ok
        end

        private

        def find_room
          @room = Room.find_by!(friendly_id: params[:friendly_id])
        end

        def online_server_rooms(rooms)
          online_rooms = BigBlueButtonApi.new.active_meetings
          online_rooms_hash = {}

          online_rooms.each do |online_room|
            online_rooms_hash[online_room[:meetingID]] = online_room[:participantCount]
          end

          rooms.each do |room|
            room.online = online_rooms_hash.key?(room.meeting_id)
            room.participants = online_rooms_hash[room.meeting_id]
          end
        end
      end
    end
  end
end
