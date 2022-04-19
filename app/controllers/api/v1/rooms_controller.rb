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

        render_json data: rooms, status: :ok
      end

      def show
        render_json data: @room, status: :ok
      end

      def destroy
        Room.destroy_by(friendly_id: params[:friendly_id])
        render_json status: :ok
      end

      # POST /api/v1/rooms/:friendly_id/start.json
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Starts the Room meeting and joins in the meeting starter.
      def start
        # TODO: amir - Check the legitimately of the action.
        bbb_api = BigBlueButtonApi.new
        meeting_starter = current_user ? "user(id):#{current_user.id}" : 'unauthenticated user'
        options = { logoutURL: request.headers['Referer'] || root_url }
        retries = 0
        begin
          logger.info "Starting meeting for room(friendly_id):#{@room.friendly_id} by #{meeting_starter}."
          join_url = bbb_api.start_meeting room: @room, meeting_starter: current_user, options: options
          logger.info "meeting successfully started for room(friendly_id):#{@room.friendly_id} by #{meeting_starter}."

          render_json data: { join_url: }, status: :created
        rescue BigBlueButton::BigBlueButtonException => e
          retries += 1
          logger.info "Retrying meeting start for room(friendly_id):#{@room.friendly_id} because of error(key): #{e.key} #{retries} times..."
          retry unless retries >= 3
          raise e
        end
      end

      # POST /api/v1/rooms.json
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: creates a room for the authenticated user.
      def create
        # TODO: amir - ensure accessibility for unauthenticated requests only.
        room = Room.create!(room_params.merge(user_id: current_user.id))
        logger.info "room(friendly_id):#{room.friendly_id} created for user(id):#{current_user.id}"
        render_json status: :created
      end

      private

      def find_room
        @room = Room.find_by!(friendly_id: params[:friendly_id])
      end

      def room_params
        params.require(:room).permit(:name)
      end
    end
  end
end
