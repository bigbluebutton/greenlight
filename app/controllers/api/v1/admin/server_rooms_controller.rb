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
          rooms = Room.includes(:user).with_provider(current_provider).search(params[:search])

          pagy, rooms = pagy(rooms)

          active_rooms = BigBlueButtonApi.new.active_meetings
          active_rooms_hash = {}

          active_rooms.each do |active_room|
            active_rooms_hash[active_room[:meetingID]] = active_room[:participantCount]
          end

          @rooms.each do |room|
            room.active = active_rooms_hash.key?(room.meeting_id)
            room.participants = active_rooms_hash[room.meeting_id]
          end

          render_data data: @rooms, meta: pagy_metadata(pagy), serializer: ServerRoomSerializer, status: :ok
        end
      end
    end
  end
end
