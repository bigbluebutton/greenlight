# frozen_string_literal: true

module Api
  module V1
    class RoomsController < ApplicationController
      skip_before_action :verify_authenticity_token # TODO: amir - Revisit this.
      before_action :find_room, only: %i[show start recordings join status]

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
        MeetingStarter.new(room: @room, logout_url: request.referer).call

        render_json data: {
          join_url: BigBlueButtonApi.new.join_meeting(room: @room, name: current_user.name, role: 'Moderator')
        }, status: :created
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

      # GET /api/v1/rooms/:friendly_id/recordings.json
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: gets the recordings that belong to the specific room friendly_id
      def recordings
        render_json(data: @room.recordings, status: :ok, include: :formats)
      end

      # GET /api/v1/rooms/:friendly_id/join.json
      def join
        render_json(data: BigBlueButtonApi.new.join_meeting(room: @room, name: params[:name], role: 'Viewer'), status: :ok)
      end

      # GET /api/v1/rooms/:friendly_id/status.json
      def status
        data = {
          status: BigBlueButtonApi.new.meeting_running?(room: @room)
        }
        data[:joinUrl] = BigBlueButtonApi.new.join_meeting(room: @room, name: params[:name], role: 'Viewer') if data[:status]

        render_json(data:, status: :ok)
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
