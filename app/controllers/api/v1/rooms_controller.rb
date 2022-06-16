# frozen_string_literal: true

module Api
  module V1
    class RoomsController < ApiController
      skip_before_action :verify_authenticity_token # TODO: amir - Revisit this.
      before_action :find_room,
                    only: %i[show update recordings recordings_processing
                             purge_presentation access_codes viewer_access_code
                             remove_viewer_access_code]

      include Avatarable
      include Presentable

      # GET /api/v1/rooms.json
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

      # GET /api/v1/rooms/:friendly_id.json
      def show
        room = {
          id: @room.id,
          name: @room.name,
          presentation_name: presentation_name(@room),
          thumbnail: presentation_thumbnail(@room),
          created_at: @room.created_at.strftime('%A %B %e, %Y %l:%M%P'),
          viewer_access_code: @room.viewer_access_code.present?
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
      def create
        # TODO: amir - ensure accessibility for unauthenticated requests only.
        room = Room.create!(room_params.merge(user_id: current_user.id))
        logger.info "room(friendly_id):#{room.friendly_id} created for user(id):#{current_user.id}"
        render_json status: :created
      end

      def update
        if @room.update(presentation: params[:presentation])
          render_json status: :ok
        else
          render_json errors: @room.errors.to_a, status: :bad_request
        end
      end

      def destroy
        Room.destroy_by(friendly_id: params[:friendly_id])
        render_json status: :ok
      end

      def purge_presentation
        @room.presentation.purge

        render_json status: :ok
      end

      # GET /api/v1/rooms/:friendly_id/recordings.json
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
            formats: recording.formats,
            record_id: recording.record_id
          }
        end

        render_json data: recordings, status: :ok
      end

      # GET /api/v1/rooms/:friendly_id/recordings_processing.json
      def recordings_processing
        render_json data: @room.recordings_processing, status: :ok
      end

      # GET /api/v1/rooms/:friendly_id/access_code.json
      def access_codes
        access_codes = {
          viewer_access_code: @room.viewer_access_code
        }

        render_json data: access_codes, status: :ok
      end

      # PATCH /api/v1/room_settings/:friendly_id/viewer_access_code.json
      def viewer_access_code
        @room.update!(viewer_access_code: SecureRandom.alphanumeric(6).downcase)
        render_json status: :ok
      end

      # PATCH /api/v1/rooms/:friendly_id/remove_viewer_access_code.json
      def remove_viewer_access_code
        @room.update!(viewer_access_code: nil)
        render_json status: :ok
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
