# frozen_string_literal: true

module Api
  module V1
    class RoomsController < ApplicationController
      skip_before_action :verify_authenticity_token # TODO: amir - Revisit this.
      before_action :find_room, only: %i[show start]

      # GET /api/v1/rooms.json
      # Returns: { data: Array[serializable objects(rooms)] , errors: Array[String] }
      # Does: Returns the Rooms that belong to the user currently logged in
      def index
        # Return the rooms that belong to current user
        rooms = Room.where(user_id: current_user&.id)

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

      # POST /api/v1/room/:friendly_id/start.json
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Starts the Room session and joins in the room starter.

      def start
        # TODO: amir - Check the legitimately of the action.
        bbb_api = BigBlueButtonApi.new
        room_id = @room.friendly_id
        session_starter = current_user ? "user(id):#{current_user.id}" : 'unauthenticated user'
        options = { logoutURL: request.headers['Referer'] || root_url }
        retries = 0
        begin
          logger.info "Starting session for room(friendly_id):#{room_id} by #{session_starter}."
          join_url = bbb_api.start_session room: @room, session_starter: current_user, options: options
          logger.info "Session successfully started for room(friendly_id):#{room_id} by #{session_starter}."

          render_json data: { join_url: }, status: :created
        rescue BigBlueButton::BigBlueButtonException => e
          retries += 1
          logger.info "Retrying session start for room(friendly_id):#{room_id} because of error(key): #{e.key} #{retries} times..."
          retry unless retries >= 3
          raise e
        end
      end

      private

      def find_room
        @room = Room.find_by!(friendly_id: params[:friendly_id])
      end
    end
  end
end
