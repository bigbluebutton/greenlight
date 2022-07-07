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

        render_data data: options, each_serializer: RoomSettingsSerializer
      end

      # PATCH /api/v1/room_settings/:friendly_id
      def update
        RoomMeetingOption
          .includes(:meeting_option)
          .joins(:meeting_option)
          .where(room_id: @room.id)
          .where(meeting_option: { name: room_setting_params[:settingName] })
          .update(value: room_setting_params[:settingValue].to_s)

        render_data
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
