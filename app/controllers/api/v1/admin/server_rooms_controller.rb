# frozen_string_literal: true

module Api
  module V1
    module Admin
      class ServerRoomsController < ApiController
        before_action :find_server_room, only: :destroy


        # GET /api/v1/admin/server_rooms.json
        def index
          rooms = Room.all.includes(:user).search(params[:search])
          active_server_rooms = BigBlueButtonApi.new.active_meetings

          # returns an array of hashes with meetingID as key and participants as value
          active_server_rooms.map! do |room|
            {
              room[:meetingID] => room[:participantCount]
            }
          end

          render_data data: rooms, each_serializer: ServerRoomSerializer, options: { active_server_rooms: }
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
