# frozen_string_literal: true

module Api
  module V1
    module Admin
      class ServerRoomsController < ApiController
        before_action :find_server_room, only: :destroy
        before_action :ensure_manage_rooms, only: %i[index destroy]

        # GET /api/v1/admin/server_rooms.json
        def index
          pagy, rooms = pagy_array(Room.includes(:user).search(params[:search]))
          active_rooms = BigBlueButtonApi.new.active_meetings
          active_rooms_hash = {}

          active_rooms.each do |active_room|
            active_rooms_hash[active_room[:meetingID]] = active_room[:participantCount]
          end

          rooms.each do |room|
            room.active = active_rooms_hash.key?(room.meeting_id)
            room.participants = active_rooms_hash[room.meeting_id]
          end

          render_data data: rooms, meta: pagy_metadata(pagy), serializer: ServerRoomSerializer, status: :ok
        end

        # DELETE /api/v1/admin/server_rooms/:friendly_id
        # Expects: {}
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Deletes the given server room.
        def destroy
          @server_room.destroy!
          render_data status: :ok
        end

        private

        def find_server_room
          @server_room = Room.find_by!(friendly_id: params[:friendly_id])
        end
      end
    end
  end
end
