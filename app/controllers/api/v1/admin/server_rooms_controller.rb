# frozen_string_literal: true

module Api
  module V1
    module Admin
      class ServerRoomsController < ApiController
        before_action only: %i[index] do
          ensure_authorized('ManageRooms')
        end

        # GET /api/v1/admin/server_rooms.json
        def index
          sort_config = config_sorting(allowed_columns: %w[name user.name])

          rooms = Room.includes(:user).with_provider(current_provider).order(sort_config, online: :desc)&.search(params[:search])

          online_server_rooms(rooms)

          pagy, rooms = pagy_array(rooms)

          render_data data: rooms, meta: pagy_metadata(pagy), serializer: ServerRoomSerializer, status: :ok
        end

        private

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
