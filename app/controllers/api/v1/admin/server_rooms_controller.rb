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

          rooms = RunningMeetingChecker.new(rooms:).call

          render_data data: rooms, meta: pagy_metadata(pagy), serializer: ServerRoomSerializer, status: :ok
        end
      end
    end
  end
end
