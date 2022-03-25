# frozen_string_literal: true

module Api
  module V1
    class RoomsController < ApplicationController

      # GET /api/v1/rooms.json
      # Returns: { data: Array[serializable objects(rooms)] , errors: Array[String] }
      # Does: Returns the Rooms that belong to the user currently logged in
      def index
        # Return the rooms that belong to current user
        rooms = Room.where(user_id: 1)
        # TODO: -hadi Replace the above line with the following:
        # rooms = Room.where(user_id: current_user.id)

        render json: {
          data: rooms,
          errors: []
        }, status: :ok
      end
    end
  end
end
