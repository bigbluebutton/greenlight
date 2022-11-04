# frozen_string_literal: true

module Api
  module V1
    class RoomsController < ApiController
      skip_before_action :ensure_authenticated, only: %i[public_show]

      before_action :find_room, only: %i[show update destroy recordings recordings_processing purge_presentation public_show]

      before_action only: %i[create index] do
        ensure_authorized('CreateRoom')
      end
      before_action only: %i[create] do
        ensure_authorized('ManageUsers', user_id: room_params[:user_id])
      end
      before_action only: %i[show] do
        ensure_authorized(%w[ManageRooms SharedRoom], friendly_id: params[:friendly_id])
      end
      before_action only: %i[update destroy recordings recordings_processing purge_presentation] do
        ensure_authorized('ManageRooms', friendly_id: params[:friendly_id])
      end

      # GET /api/v1/rooms.json
      def index
        shared_rooms = SharedAccess.where(user_id: current_user.id).select(:room_id)
        rooms = Room.where(user_id: current_user.id)
                    .or(Room.where(id: shared_rooms))
                    .order(online: :desc)
                    .order(Room.arel_table[:last_session].desc.nulls_last)
                    .search(params[:search])

        rooms.map do |room|
          room.shared = true if room.user_id != current_user.id
        end

        RunningMeetingChecker.new(rooms:).call

        render_data data: rooms, status: :ok
      end

      # GET /api/v1/rooms/:friendly_id.json
      def show
        RunningMeetingChecker.new(rooms: @room).call if @room.online

        @room.shared = current_user.shared_rooms.include?(@room)

        render_data data: @room, serializer: CurrentRoomSerializer, status: :ok
      end

      # GET /api/v1/rooms/:friendly_id/public.json
      def public_show
        settings = RoomSettingsGetter.new(
          room_id: @room.id,
          provider: current_provider,
          current_user:,
          show_codes: false,
          settings: %w[glRequireAuthentication glViewerAccessCode glModeratorAccessCode record]
        ).call

        render_data data: @room, serializer: PublicRoomSerializer, options: { settings: }, status: :ok
      end

      # POST /api/v1/rooms.json
      def create
        return render_error status: :bad_request, errors: 'RoomLimitError' unless PermissionsChecker.new(
          permission_names: 'RoomLimit',
          user_id: room_params[:user_id], current_user:, friendly_id: nil, record_id: nil
        ).call

        # TODO: amir - ensure accessibility for authenticated requests only.
        # The created room will be the current user's unless a user_id param is provided with the request.
        room = Room.new(name: room_params[:name], user_id: room_params[:user_id])

        if room.save
          logger.info "room(friendly_id):#{room.friendly_id} created for user(id):#{room.user_id}"
          render_data status: :created
        else
          render_error errors: room.errors.to_a, status: :bad_request
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
