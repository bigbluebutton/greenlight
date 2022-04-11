# frozen_string_literal: true

module Api
  module V1
    class RoomsController < ApplicationController
      skip_before_action :verify_authenticity_token # TODO: amir - Revisit this.
      before_action :find_room, only: :show

      # GET /api/v1/rooms.json
      # Returns: { data: Array[serializable objects(rooms)] , errors: Array[String] }
      # Does: Returns the Rooms that belong to the user currently logged in
      def index
        # Return the rooms that belong to current user
        rooms = Room.where(user_id: current_user&.id)

        render_json data: rooms, status: :ok
      end

      def show
        render_json data: @room, status: :ok
      end

      private

      def find_room
        @room = Room.find_by!(friendly_id: params[:friendly_id])
      end
    end
  end
end
