# frozen_string_literal: true

module Api
  module V1
    class RoomsController < ApiController
      skip_before_action :verify_authenticity_token # TODO: amir - Revisit this.
      before_action :find_room, only: %i[show recordings]

      include Avatarable
      include Presentation

      # GET /api/v1/rooms.json
      # Returns: { data: Array[serializable objects(rooms)] , errors: Array[String] }
      # Does: Returns the Rooms that belong to the user currently logged in
      def index
        # Return the rooms that belong to current user
        rooms = Room.where(user_id: current_user&.id).to_a

        shared_rooms = current_user.shared_rooms.map do |room|
          {
            id: room.id,
            name: room.name,
            friendly_id: room.friendly_id,
            created_at: room.created_at.strftime('%A %B %e, %Y %l:%M%P'),
            shared: true,
            shared_owner: room.user.name
          }
        end

        rooms.map! do |room|
          {
            id: room.id,
            name: room.name,
            friendly_id: room.friendly_id,
            created_at: room.created_at.strftime('%A %B %e, %Y %l:%M%P')
          }
        end

        render_json data: rooms + shared_rooms, status: :ok
      end

      def show
        # TODO: samuel - should probably create/use a UUID instead of object id
        room = {
          id: @room.id,
          name: @room.name,
          presentation: room_presentation(@room),
          created_at: @room.created_at.strftime('%A %B %e, %Y %l:%M%P')
        }

        if params[:include_owner] == 'true'
          room[:owner] = {
            name: @room.user.name,
            avatar: user_avatar(@room.user)
          }
        end

        render_json data: room, status: :ok
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

      def update
        room = Room.find_by(friendly_id: params[:friendly_id])
        if room.update(presentation: params[:presentation])
          render_json status: :ok
        else
          render_json errors: room.errors.to_a, status: :bad_request
        end
      end

      def destroy
        Room.destroy_by(friendly_id: params[:friendly_id])
        render_json status: :ok
      end

      # GET /api/v1/rooms/:friendly_id/recordings.json
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: gets the recordings that belong to the specific room friendly_id
      def recordings
        recordings = @room.recordings&.search(params[:q]).to_a

        recordings.map! do |recording|
          {
            id: recording.id,
            name: recording.name,
            length: recording.length,
            users: recording.users,
            visibility: recording.visibility,
            created_at: recording.created_at.strftime('%A %B %e, %Y %l:%M%P'),
            formats: recording.formats
          }
        end

        render_json data: recordings, status: :ok
      end

      private

      def find_room
        @room = Room.find_by!(friendly_id: params[:friendly_id])
      end

      def room_params
        params.require(:room).permit(:name, :presentation)
      end
    end
  end
end
