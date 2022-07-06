# frozen_string_literal: true

module Api
  module V1
    module Admin
      class ServerRoomsController < ApiController
        before_action :find_server_room, only: :destroy

        # GET /api/v1/admin/server_rooms.json
        def index
          rooms = Room.all.search(params[:search])

          active_server_rooms = BigBlueButtonApi.new.active_meetings

          active_server_rooms_ids = active_server_rooms.pluck(:meetingID)
          active_server_rooms_participants = active_server_rooms.pluck(:participantCount)

          rooms.map! do |room|
            {
              friendly_id: room.friendly_id,
              name: room.name,
              owner: User.find(room.user_id).name,
              status: active_server_rooms_ids.include?(room.meeting_id) ? 'Active' : 'Not Running',
              participants: active_server_rooms_ids.include?(room.meeting_id) ? active_server_rooms_participants[active_server_rooms_ids.index(room.meeting_id)] : '-'
            }
          end

          render_json data: rooms, status: :ok
        end

        # DELETE /api/v1/admin/server_rooms/:friendly_id
        # Expects: {}
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Deletes the given server room.
        def destroy
          @server_room.destroy!
          render_json
        end

        private

        def find_server_room
          @server_room = Room.find_by!(friendly_id: params[:friendly_id])
        end
      end
    end
  end
end
