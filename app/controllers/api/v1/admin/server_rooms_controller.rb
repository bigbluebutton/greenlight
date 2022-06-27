# frozen_string_literal: true

module Api
  module V1
    module Admin
      class ServerRoomsController < ApiController

        def index
          rooms = Room.all.search(params[:search])

          rooms.map! do |room|
            {
              friendly_id: room.friendly_id,
              name: room.name,
              owner: User.find(room.user_id).name,
            }
          end

          render_json data: rooms, status: :ok
        end
      end
    end
  end
end
