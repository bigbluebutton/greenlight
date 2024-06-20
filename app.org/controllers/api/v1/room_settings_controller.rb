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
    class RoomSettingsController < ApiController
      before_action :find_room, only: %i[show update]

      before_action only: %i[show update] do
        ensure_authorized(%w[ManageRooms SharedRoom], friendly_id: params[:friendly_id])
      end

      # GET /api/v1/room_settings/:friendly_id
      # Returns all room settings including the access codes but without those disabled through room configs
      def show
        options = RoomSettingsGetter.new(room_id: @room.id, provider: current_provider, current_user:, show_codes: true,
                                         only_enabled: true).call

        render_data data: options, status: :ok
      end

      # PATCH /api/v1/room_settings/:friendly_id
      # Updates a room's settings if the room config is set to optional or default
      def update
        name = room_setting_params[:settingName]
        value = room_setting_params[:settingValue].to_s

        config = MeetingOption.get_config_value(name:, provider: current_provider)
        config_value = config[name]

        return render_error status: :bad_request unless config_value

        is_access_code = %w[glViewerAccessCode glModeratorAccessCode].include? name

        # Only allow the settings to update if the room config is default or optional / if it is an access_code regeneration
        unless %w[optional default_enabled].include?(config_value) || (config_value == 'true' && is_access_code && value != 'false')
          return render_error status: :forbidden
        end

        value = infer_access_code(value:) if is_access_code # Handling access code update.

        option = @room.get_setting(name:)

        return render_error status: :bad_request unless option&.update(value:)

        render_data status: :ok
      end

      private

      def find_room
        @room = Room.find_by!(friendly_id: params[:friendly_id])
      end

      def room_setting_params
        params.require(:room_setting).permit(:settingValue, :settingName)
      end

      def infer_access_code(value:)
        # Access code update logic maps 'false' -> removing a code & <OTHER> -> generating a code.
        value == 'false' ? '' : generate_code
      end

      # TODO: Amir - Check if we could extract all GL3 codes generation into a service.
      def generate_code
        SecureRandom.alphanumeric(6).downcase
      end
    end
  end
end
