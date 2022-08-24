# frozen_string_literal: true

module Api
  module V1
    class RoomSettingsController < ApiController
      before_action :find_room, only: %i[show update]

      # GET /api/v1/room_settings/:friendly_id
      def show
        options = RoomSettingsGetter.new(room_id: @room.id, provider: current_provider, show_codes: true, only_enabled: true).call

        render_data data: options, status: :ok
      end

      # PATCH /api/v1/room_settings/:friendly_id
      def update
        config = MeetingOption.get_config_value(name: room_setting_params[:settingName], provider: current_provider)&.value
        return render_error status: :bad_request unless config

        name = room_setting_params[:settingName]
        value = room_setting_params[:settingValue].to_s

        is_access_code = %w[glViewerAccessCode glModeratorAccessCode].include? name

        return render_error status: :forbidden unless config == 'optional' || (config == 'true' && is_access_code && value != 'false')

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

      # TODO: Check if we could extract all GL3 codes generation into a service.
      def generate_code
        SecureRandom.alphanumeric(6).downcase
      end
    end
  end
end
