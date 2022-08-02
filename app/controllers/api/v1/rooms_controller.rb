# frozen_string_literal: true

module Api
  module V1
    class RoomsController < ApiController
      before_action :find_room,
                    only: %i[show update recordings recordings_processing
                             purge_presentation access_codes
                             generate_access_code remove_access_code]

      skip_before_action :ensure_authenticated, only: %i[show]

      include Avatarable
      include Presentable

      # GET /api/v1/rooms.json
      def index
        # Return the rooms that belong to current user
        rooms = Room.where(user_id: current_user&.id)

        shared_rooms = current_user.shared_rooms.map do |room|
          room.shared = true
          room
        end

        render_data data: rooms + shared_rooms, status: :ok
      end

      # GET /api/v1/rooms/:friendly_id.json
      def show
        render_data data: @room, serializer: CurrentRoomSerializer, options: { include_owner: params[:include_owner] == 'true' }, status: :ok
      end

      # POST /api/v1/rooms.json
      def create
        # TODO: amir - ensure accessibility for authenticated requests only.
        room = Room.create!(room_create_params.merge(user_id: current_user.id))
        logger.info "room(friendly_id):#{room.friendly_id} created for user(id):#{current_user.id}"
        render_data status: :created
      end

      def update
        if @room.update(presentation: params[:presentation])
          render_data status: :ok
        else
          render_error errors: @room.errors.to_a, status: :bad_request
        end
      end

      def destroy
        Room.destroy_by(friendly_id: params[:friendly_id])
        render_data status: :ok
      end

      def purge_presentation
        @room.presentation.purge

        render_data status: :ok
      end

      # GET /api/v1/rooms/:friendly_id/recordings.json
      def recordings
        pagy, room_recordings = pagy(@room.recordings&.search(params[:q]))
        render_data data: room_recordings, meta: pagy_metadata(pagy), status: :ok
      end

      # GET /api/v1/rooms/:friendly_id/recordings_processing.json
      def recordings_processing
        render_data data: @room.recordings_processing, status: :ok
      end

      # GET /api/v1/rooms/:friendly_id/access_code.json
      def access_codes
        access_codes = {
          viewer_access_code: @room.viewer_access_code,
          moderator_access_code: @room.moderator_access_code
        }

        render_data data: access_codes, status: :ok
      end

      # PATCH /api/v1/room_settings/:friendly_id/viewer_access_code.json
      def generate_access_code
        generated = case params[:bbb_role]
                    when 'Viewer'
                      @room.generate_viewer_access_code
                    when 'Moderator'
                      @room.generate_moderator_access_code
                    end

        return render_error status: :bad_request unless generated

        render_data status: :ok
      end

      # PATCH /api/v1/room_settings/:friendly_id/remove_viewer_access_code.json
      def remove_access_code
        removed = case params[:bbb_role]
                  when 'Viewer'
                    @room.remove_viewer_access_code
                  when 'Moderator'
                    @room.remove_moderator_access_code
                  end

        return render_error status: :bad_request unless removed

        render_data status: :ok
      end

      private

      def find_room
        @room = Room.find_by!(friendly_id: params[:friendly_id])
      end

      def room_create_params
        params.require(:room).permit(:name)
      end
    end
  end
end
