# frozen_string_literal: true

module Api
  module V1
    class MeetingsController < ApiController
      skip_before_action :verify_authenticity_token # TODO: amir - Revisit this.
      before_action :find_room, only: %i[start join status]

      # POST /api/v1/rooms/:friendly_id/start.json
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Starts the Room meeting and joins in the meeting starter.
      def start
        presentation_url = (url_for(@room.presentation).gsub('&', '%26') if @room.presentation.attached?)

        MeetingStarter.new(room: @room, logout_url: request.referer, presentation_url:).call

        render_json data: {
          join_url: BigBlueButtonApi.new.join_meeting(room: @room, name: current_user.name, role: 'Moderator')
        }, status: :created
      end

      # GET /api/v1/rooms/:friendly_id/join.json
      def join
        render_json(data: BigBlueButtonApi.new.join_meeting(room: @room, name: params[:name], role: 'Viewer'), status: :ok)
      end

      # GET /api/v1/rooms/:friendly_id/status.json
      def status
        data = {
          status: BigBlueButtonApi.new.meeting_running?(room: @room)
        }
        data[:joinUrl] = BigBlueButtonApi.new.join_meeting(room: @room, name: params[:name], role: 'Viewer') if data[:status]

        render_json(data:, status: :ok)
      end

      private

      def find_room
        @room = Room.find_by!(friendly_id: params[:friendly_id])
      end
    end
  end
end
