# frozen_string_literal: true

module Api
  module V1
    class RoomSettingsController < ApplicationController
      skip_before_action :verify_authenticity_token # TODO: amir - Revisit this.
      before_action :find_room, only: %i[show update]

      def show
        options = MeetingOption
                  .joins(:room_meeting_options)
                  .where(room_meeting_options: { room_id: @room.id })
                  .select(:name, :value)

        render_json(data: options, status: :ok)
      end

      def update
        RoomMeetingOption
          .includes(:meeting_option)
          .joins(:meeting_option)
          .where(room_id: @room.id)
          .where(meeting_option: { name: room_setting_params[:settingName] })
          .update(value: room_setting_params[:settingValue].to_s)

        render_json(status: :ok)
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
