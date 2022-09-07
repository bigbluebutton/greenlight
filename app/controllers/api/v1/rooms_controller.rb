# frozen_string_literal: true

module Api
  module V1
    class RoomsController < ApiController
      skip_before_action :ensure_authenticated, only: %i[public_show]

      before_action :find_room, only: %i[show update destroy recordings recordings_processing purge_presentation public_show]
      before_action do
        ensure_authorized('CreateRoom')
      end
      before_action only: %i[create] do
        ensure_authorized('ManageUsers', user_id: room_params[:user_id])
      end
      before_action only: %i[show destroy] do
        ensure_authorized('ManageRooms', friendly_id: params[:friendly_id])
      end

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

      # GET /api/v1/rooms/:friendly_id/public.json
      def public_show
        settings = RoomSettingsGetter.new(
          room_id: @room.id,
          provider: current_provider,
          current_user:,
          show_codes: false,
          settings: %w[glRequireAuthentication glViewerAccessCode glModeratorAccessCode]
        ).call

        render_data data: @room, serializer: PublicRoomSerializer, options: { settings: }, status: :ok
      end

      # POST /api/v1/rooms.json
      def create
        # TODO: amir - ensure accessibility for authenticated requests only.
        # The created room will be the current user's unless a user_id param is provided with the request.
        # user_id = room_params[:user_id]
        room = Room.create(name: room_params[:name], user_id: room_params[:user_id])

        return render_error errors: user.errors.to_a if hcaptcha_enabled? && !verify_hcaptcha(response: params[:token])

        if room.save
          logger.info "room(friendly_id):#{room.friendly_id} created for user(id):#{room.user_id}"
          render_data status: :created
        else
          render_error status: :bad_request
        end
      end

      def update
        if @room.update(room_params)
          render_data status: :ok
        else
          render_error errors: @room.errors.to_a, status: :bad_request
        end
      end

      def destroy
        if @room.destroy
          render_data status: :ok
        else
          render_error errors: @room.errors.to_a, status: :bad_request
        end
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

      private

      def find_room
        @room = Room.find_by!(friendly_id: params[:friendly_id])
      end

      def room_params
        params.require(:room).permit(:name, :user_id, :presentation)
      end
    end
  end
end
