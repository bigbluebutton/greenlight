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
      GLOBAL_PRESENTATION_TEMPLATES = [
        {
          key: 'akademio-default-en',
          name: 'akademio live default presentation.pdf',
          file_name: 'akademio-live-default-presentation.pdf',
          content_type: 'application/pdf'
        },
        {
          key: 'akademio-default-tr',
          name: 'akademio live default presentation (TR).pdf',
          file_name: 'akademio-live-default-presentation-tr.pdf',
          content_type: 'application/pdf'
        }
      ].freeze

      skip_before_action :ensure_authenticated, only: %i[public_show public_recordings]
      skip_before_action :ensure_valid_request, only: %i[global_presentation_template_file]

      before_action :find_room, only: %i[
        show
        update
        destroy
        recordings
        recordings_processing
        presentation_library
        purge_presentation
        purge_thumbnail_image
        use_presentation_template
        use_global_presentation_template
        public_show
        public_recordings
      ]

      before_action only: %i[create] do
        ensure_authorized('CreateRoom')
      end
      before_action only: %i[create] do
        ensure_authorized('ManageUsers', user_id: room_params[:user_id])
      end
      before_action only: %i[presentation_library_for_user] do
        target_user_id = requested_presentation_library_user_id

        if target_user_id.to_s == current_user.id.to_s
          ensure_authorized('CreateRoom')
        else
          ensure_authorized('ManageUsers', user_id: target_user_id)
        end
      end
      before_action only: %i[
        show
        update
        recordings
        recordings_processing
        presentation_library
        purge_thumbnail_image
        use_presentation_template
        use_global_presentation_template
      ] do
        ensure_authorized(%w[ManageRooms SharedRoom], friendly_id: params[:friendly_id])
      end
      before_action only: %i[purge_presentation] do
        ensure_authorized('ManageRooms', friendly_id: params[:friendly_id])
      end
      before_action only: %i[destroy] do
        ensure_authorized('ManageRooms', friendly_id: params[:friendly_id])
      end

      # GET /api/v1/rooms.json
      # Returns a list of the current_user's rooms and shared rooms
      def index
        shared_rooms = SharedAccess.where(user_id: current_user.id).select(:room_id)
        rooms = Room.includes(:user)
                    .where(user_id: current_user.id)
                    .or(Room.where(id: shared_rooms))
                    .order(online: :desc)
                    .order('last_session DESC NULLS LAST')
                    .search(params[:search])

        rooms.map do |room|
          room.shared = true if room.user_id != current_user.id
        end

        RunningMeetingChecker.new(rooms: rooms.select(&:online)).call if rooms.any?(&:online)

        render_data data: rooms, status: :ok
      end

      # GET /api/v1/rooms/:friendly_id.json
      # Returns the info on a specific room
      def show
        RunningMeetingChecker.new(rooms: @room).call if @room.online

        @room.shared = current_user.shared_rooms.include?(@room)

        render_data data: @room, serializer: CurrentRoomSerializer, status: :ok
      end

      # GET /api/v1/rooms/:friendly_id/presentation_library.json
      # Returns the room owner's owned and shared rooms for presentation reuse
      def presentation_library
        accessible_rooms = presentation_library_rooms_for(@room.user)

        render_data data: accessible_rooms, serializer: RoomSerializer, status: :ok
      end

      # GET /api/v1/rooms/presentation_library_for_user.json
      # Returns the specified user's owned and shared presentation library for room creation
      def presentation_library_for_user
        accessible_rooms = presentation_library_rooms_for(requested_presentation_library_user)

        render_data data: accessible_rooms, serializer: RoomSerializer, status: :ok
      end

      # GET /api/v1/rooms/global_presentation_templates.json
      # Returns globally-available presentation templates for all users and rooms
      def global_presentation_templates
        render_data data: available_global_presentation_templates.map { |template|
          {
            key: template[:key],
            name: template[:name],
            url: global_presentation_template_file_path(template[:key]),
            content_type: template[:content_type],
            byte_size: template[:byte_size],
            created_at: template[:created_at],
            shared_owner: 'Akademio Live',
            room_name: 'Akademio Library',
            protected: true
          }
        }, status: :ok
      end

      # GET /api/v1/rooms/global_presentation_templates/:template_key/file
      # Streams the selected global presentation template file
      def global_presentation_template_file
        template = global_presentation_template_by_key(params[:template_key].to_s)
        return render_error errors: ['Global template not found'], status: :not_found unless template

        send_file(
          template[:path],
          filename: template[:name],
          type: template[:content_type],
          disposition: 'inline'
        )
      end

      # GET /api/v1/rooms/:friendly_id/public.json
      # Returns all publicly available information required for a room to be joined
      def public_show
        settings = RoomSettingsGetter.new(
          room_id: @room.id,
          provider: current_provider,
          current_user:,
          show_codes: false,
          settings: %w[glRequireAuthentication glViewerAccessCode glModeratorAccessCode record glAnyoneJoinAsModerator]
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

        owner = User.find(room_params[:user_id])
        source_friendly_id = room_params[:source_friendly_id].to_s.strip
        global_source_key = room_params[:global_source_key].to_s.strip
        source_room = nil
        global_template = nil

        if room_params[:presentation].blank? && source_friendly_id.present?
          source_room = find_source_presentation_room(owner, source_friendly_id)
          return render_error errors: ['Source room not found'], status: :not_found unless source_room
          return render_error errors: ['Source room has no presentation'], status: :bad_request unless source_room.presentation.attached?
        end

        if room_params[:presentation].blank? && source_room.nil? && global_source_key.present?
          global_template = global_presentation_template_by_key(global_source_key)
          return render_error errors: ['Global template not found'], status: :not_found unless global_template
        end

        # TODO: amir - ensure accessibility for authenticated requests only.
        # The created room will be the current user's unless a user_id param is provided with the request.
        room = Room.new(name: room_params[:name], user_id: room_params[:user_id])
        room.icon_key = room_params[:icon_key] if room_params[:icon_key].present?
        room.presentation.attach(room_params[:presentation]) if room_params[:presentation].present?
        room.thumbnail_image.attach(room_params[:thumbnail_image]) if room_params[:thumbnail_image].present?

        if room.save
          room.presentation.attach(source_room.presentation.blob) if source_room
          attach_global_presentation_to_room(room, global_template) if global_template
          logger.info "room(friendly_id):#{room.friendly_id} created for user(id):#{room.user_id}"
          render_data data: "/rooms/#{room.friendly_id}", status: :created
        else
          render_error errors: room.errors.to_a, status: :bad_request
        end
      end

      # PATCH /api/v1/rooms/:friendly_id.json
      # Updates the values of the specified room
      def update
        update_attributes = {}
        update_attributes[:name] = room_params[:name] if room_params[:name].present?
        update_attributes[:icon_key] = room_params[:icon_key] if room_params[:icon_key].present?

        @room.assign_attributes(update_attributes)
        @room.presentation.attach(room_params[:presentation]) if room_params[:presentation].present?
        @room.thumbnail_image.attach(room_params[:thumbnail_image]) if room_params[:thumbnail_image].present?

        if @room.save
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

      # DELETE /api/v1/rooms/${friendlyId}/purge_thumbnail_image.json
      # Removes the thumbnail image attached to the room
      def purge_thumbnail_image
        @room.thumbnail_image.purge

        render_data status: :ok
      end

      # POST /api/v1/rooms/:friendly_id/use_presentation_template.json
      # Attaches another room from the current room owner's library as this room's presentation
      def use_presentation_template
        source_friendly_id = params[:source_friendly_id].to_s.strip
        return render_error errors: ['Source presentation is required'], status: :bad_request if source_friendly_id.blank?

        source_room = find_source_presentation_room(@room.user, source_friendly_id)
        return render_error errors: ['Source room not found'], status: :not_found unless source_room
        return render_error errors: ['Source room has no presentation'], status: :bad_request unless source_room.presentation.attached?

        @room.presentation.attach(source_room.presentation.blob)
        render_data status: :ok
      end

      # POST /api/v1/rooms/:friendly_id/use_global_presentation_template.json
      # Attaches a protected global template as this room's presentation
      def use_global_presentation_template
        global_source_key = params[:global_source_key].to_s.strip
        return render_error errors: ['Global template is required'], status: :bad_request if global_source_key.blank?

        template = global_presentation_template_by_key(global_source_key)
        return render_error errors: ['Global template not found'], status: :not_found unless template

        attach_global_presentation_to_room(@room, template)
        render_data status: :ok
      end

      # GET /api/v1/rooms/:friendly_id/recordings.json
      # Returns all of a specific room's recordings
      def recordings
        sort_config = config_sorting(allowed_columns: %w[name length visibility])
        items = params[:items].to_i
        items = 3 if items <= 0 || items > 100

        pagy, room_recordings = pagy(
          @room.recordings&.order(sort_config, recorded_at: :desc)&.search(params[:search]),
          items:
        )
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

      def requested_presentation_library_user_id
        params[:user_id].presence || current_user.id
      end

      def requested_presentation_library_user
        @requested_presentation_library_user ||= User.find(requested_presentation_library_user_id)
      end

      def presentation_library_scope_for(owner)
        shared_room_ids = SharedAccess.where(user_id: owner.id).select(:room_id)

        Room.with_attached_presentation
            .includes(:user)
            .where(user_id: owner.id)
            .or(
              Room.with_attached_presentation
                  .includes(:user)
                  .where(id: shared_room_ids)
            )
      end

      def presentation_library_rooms_for(owner)
        presentation_library_scope_for(owner)
          .select { |room| room.presentation.attached? }
          .sort_by do |room|
            room.presentation.attachment&.created_at || room.last_session || Time.zone.at(0)
          end
          .reverse
          .tap do |rooms|
            rooms.each do |room|
              room.shared = room.user_id != owner.id
            end
          end
      end

      def find_source_presentation_room(owner, source_friendly_id)
        presentation_library_scope_for(owner).find_by(friendly_id: source_friendly_id)
      end

      def available_global_presentation_templates
        GLOBAL_PRESENTATION_TEMPLATES.filter_map do |template|
          file_path = Rails.root.join('public', 'default_presentations', template[:file_name])
          next unless File.file?(file_path)

          {
            key: template[:key],
            name: template[:name],
            path: file_path.to_s,
            content_type: template[:content_type],
            byte_size: File.size(file_path),
            created_at: File.mtime(file_path).utc
          }
        end
      end

      def global_presentation_template_by_key(template_key)
        return if template_key.blank?

        available_global_presentation_templates.find { |template| template[:key] == template_key }
      end

      def global_presentation_template_file_path(template_key)
        "#{ENV['RELATIVE_URL_ROOT'].presence}/api/v1/rooms/global_presentation_templates/#{template_key}/file"
      end

      def attach_global_presentation_to_room(room, template)
        return if template.blank?

        File.open(template[:path], 'rb') do |file|
          room.presentation.attach(
            io: file,
            filename: template[:name],
            content_type: template[:content_type]
          )
        end
      end

      def room_params
        params.require(:room).permit(
          :name,
          :user_id,
          :presentation,
          :icon_key,
          :thumbnail_image,
          :source_friendly_id,
          :global_source_key
        )
      end
    end
  end
end
