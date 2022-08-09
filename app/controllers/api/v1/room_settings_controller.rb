# frozen_string_literal: true

module Api
  module V1
    class RoomSettingsController < ApiController
      before_action :find_room, only: %i[show update]

      # GET /api/v1/room_settings/:friendly_id
      def show
        options = MeetingOption.joins(:room_meeting_options)
                               .where(room_meeting_options: { room_id: @room.id })
                               .select(:name, :value)

        render_data data: options, serializer: RoomSettingsSerializer, status: :ok
      end

      # PATCH /api/v1/room_settings/:friendly_id
      def update
        config = MeetingOption.get_config_value(name: room_setting_params[:settingName], provider: 'greenlight')&.value

        return render_error status: :forbidden unless config == 'optional'

        option = @room.get_setting(name: room_setting_params[:settingName])

        return render_error status: :bad_request unless option&.update(value: room_setting_params[:settingValue].to_s)

        render_data status: :ok
      end

      private

      def find_room
        @room = Room.find_by!(friendly_id: params[:friendly_id])
      end

      def room_setting_params
        params.require(:room_setting).permit(:settingValue, :settingName)
      end
    end
  end
end
