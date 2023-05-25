# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

module Api
  module V1
    class RoomsController < ApiController
      skip_before_action :ensure_authenticated, only: %i[public_show public_recordings]

      before_action :find_room, only: %i[show update destroy recordings recordings_processing purge_presentation public_show public_recordings]

      before_action only: %i[create index] do
        ensure_authorized(%w[CreateRoom ApiCreateRoom])
      end
      before_action only: %i[create] do
        ensure_authorized('ApiCreateRoom')
      end
      before_action only: %i[create] do
        ensure_authorized('ManageUsers', user_id: room_params[:user_id])
      end
      before_action only: %i[show update recordings recordings_processing purge_presentation] do
        ensure_authorized(%w[ManageRooms SharedRoom], friendly_id: params[:friendly_id])
      end
      before_action only: %i[destroy] do
        ensure_authorized('ManageRooms', friendly_id: params[:friendly_id])
      end

      # GET /api/v1/rooms.json
      # Returns a list of the current_user's rooms and shared rooms
      def index
        shared_rooms = SharedAccess.where(user_id: current_user.id).select(:room_id)
        rooms = Room.where(user_id: current_user.id)
                    .or(Room.where(id: shared_rooms))
                    .order(online: :desc)
                    .order('last_session DESC NULLS LAST')
                    .search(params[:search])

        rooms.map do |room|
          room.shared = true if room.user_id != current_user.id
        end

        RunningMeetingChecker.new(rooms:, provider: current_provider).call

        render_data data: rooms, status: :ok
      end

      # GET /api/v1/rooms/:friendly_id.json
      # Returns the info on a specific room
      def show
        RunningMeetingChecker.new(rooms: @room, provider: current_provider).call if @room.online

        @room.shared = current_user.shared_rooms.include?(@room)

        render_data data: @room, serializer: CurrentRoomSerializer, status: :ok
      end

      # GET /api/v1/rooms/:friendly_id/public.json
      # Returns all publicly available information required for a room to be joined
      def public_show
        settings = RoomSettingsGetter.new(
          room_id: @room.id,
          provider: current_provider,
          current_user:,
          show_codes: false,
          settings: %w[glRequireAuthentication glViewerAccessCode glModeratorAccessCode record glAnyoneJoinAsModerator logoutURL]
        ).call

        render_data data: @room, serializer: PublicRoomSerializer, options: { settings: }, status: :ok
      end

      # POST /api/v1/rooms.json
      # Creates a room for the specified user if they are allowed to
      def create
        return render_error status: :bad_request, errors: Rails.configuration.custom_error_msgs[:room_limit] unless PermissionsChecker.new(
          permission_names: 'RoomLimit',
          user_id: room_params[:user_id], current_user:, current_provider:
        ).call

        room_id = room_params[:id] || params[:id]

        # Check if the room exists
        if room_id
          already_existing_room = Room.find_by(id: room_id, user_id: room_params[:user_id]);

          if !already_existing_room.blank?
            data = { "friendly_id" => already_existing_room.friendly_id, "user_id": already_existing_room.user_id };
            return render_data data: data, status: :ok
          end          
        end

        # Try to create the user if not exists
        user = User.find(room_params[:user_id])

        if user.blank?
          info = params[:user]
          user_info = {
            name: info[:name],
            email: info[:email],
            external_id: room_params[:user_id],
            verified: true
          }

          user = UserCreator.new(user_params: user_info, provider: current_provider, role: default_role).call
          user.assign_attributes({ id: room_params[:user_id], language: info[:language] })
          user.save!
        end


        # TODO: amir - ensure accessibility for authenticated requests only.
        # The created room will be the current user's unless a user_id param is provided with the request.
        room = Room.new(name: room_params[:name], user_id: room_params[:user_id])

        if room_id
          room.assign_attributes({ id: room_id })
        end

        if room.save
          logger.info "room(friendly_id):#{room.friendly_id} created for user(id):#{room.user_id}"

          # Assigning additional meeting options
          if params[:room][:logout_url]
            logout_url = params[:room][:logout_url]

            if logout_url
              option = room.get_setting(name: 'logoutURL')
              option&.update(value: logout_url)
            end
          end

          data = { "friendly_id" => room.friendly_id, "user_id": room.user_id };
          render_data data: data, status: :created
        else
          render_error errors: room.errors.to_a, status: :bad_request
        end
      end

      # PATCH /api/v1/rooms/:friendly_id.json
      # Updates the values of the specified room
      def update
        if @room.update(room_params)
          render_data status: :ok
        else
          render_error errors: @room.errors.to_a, status: :bad_request
        end
      end

      # DELETE /api/v1/rooms.json
      # Updates the specified room
      def destroy
        if @room.destroy
          render_data status: :ok
        else
          render_error errors: @room.errors.to_a, status: :bad_request
        end
      end

      # DELETE /api/v1/rooms/${friendlyId}/purge_presentation.json
      # Removes the presentation attached to the room
      def purge_presentation
        @room.presentation.purge

        render_data status: :ok
      end

      # GET /api/v1/rooms/:friendly_id/recordings.json
      # Returns all of a specific room's recordings
      def recordings
        sort_config = config_sorting(allowed_columns: %w[name length visibility])

        pagy, room_recordings = pagy(@room.recordings&.order(sort_config, recorded_at: :desc)&.search(params[:q]))
        render_data data: room_recordings, meta: pagy_metadata(pagy), status: :ok
      end

      # GET /api/v1/rooms/:friendly_id/public_recordings.json
      # Returns all of a specific room's PUBLIC recordings
      def public_recordings
        sort_config = config_sorting(allowed_columns: %w[name length])

        pagy, recordings = pagy(@room.public_recordings.order(sort_config, recorded_at: :desc).public_search(params[:search]))

        render_data data: recordings, meta: pagy_metadata(pagy), serializer: PublicRecordingSerializer, status: :ok
      end

      # GET /api/v1/rooms/:friendly_id/recordings_processing.json
      # Returns the total number of processing recordings for a specific room
      def recordings_processing
        render_data data: @room.recordings_processing, status: :ok
      end

      private

      def find_room
        @room = Room.find_by!(friendly_id: params[:friendly_id])
      end

      def room_params
        params.require(:room).permit(:name, :user_id, :presentation, :id, :logout_url)
      end
    end
  end
end
