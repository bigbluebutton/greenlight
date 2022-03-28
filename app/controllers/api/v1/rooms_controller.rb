# frozen_string_literal: true

module Api
  module V1
    class RoomsController < ApplicationController
      before_action :find_room, only: :show

      # GET /api/v1/rooms.json
      # Returns: { data: Array[serializable objects(rooms)] , errors: Array[String] }
      # Does: Returns the Rooms that belong to the user currently logged in
      def index
        # Return the rooms that belong to current user
        rooms = Room.where(user_id: current_user.id)

        render json: {
          data: rooms,
          errors: []
        }, status: :ok
      end

      def show
        if @room
          render json: {
            data: @room,
            errors: []
          }, status: :ok
        else
          render json: {
            data: [],
            errors: []
          }, status: :not_found
        end
      end

      private

      def find_room
        @room = Room.find_by(friendly_id: params[:friendly_id])
      end
      
    end
  end
end
