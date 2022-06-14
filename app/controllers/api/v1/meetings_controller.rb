# frozen_string_literal: true

module Api
  module V1
    class MeetingsController < ApiController
      skip_before_action :verify_authenticity_token # TODO: amir - Revisit this.
      before_action :find_room, only: %i[start join status]

      # POST /api/v1/meetings/:friendly_id/start.json
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Starts the Room meeting and joins in the meeting starter.
      def start
        presentation_url = (url_for(@room.presentation).gsub('&', '%26') if @room.presentation.attached?)

        MeetingStarter.new(
          room: @room,
          logout_url: request.referer,
          presentation_url:,
          meeting_ended: meeting_ended_url,
          recording_ready: recording_ready_url
        ).call

        render_json data: {
          join_url: BigBlueButtonApi.new.join_meeting(room: @room, name: current_user.name, role: 'Moderator')
        }, status: :created
      end

      # GET /api/v1/meetings/:friendly_id/join.json
      def join
        if authorize_access?
          render_json data: BigBlueButtonApi.new.join_meeting(room: @room, name: params[:name], role: 'Viewer'), status: :ok
        else
          render_json status: :unauthorized
        end
      end

      # GET /api/v1/meetings/:friendly_id/status.json
      def status
        data = {
          status: BigBlueButtonApi.new.meeting_running?(room: @room)
        }
        data[:joinUrl] = BigBlueButtonApi.new.join_meeting(room: @room, name: params[:name], role: 'Viewer') if data[:status]

        if authorize_access?
          render_json data:, status: :ok
        else
          render_json status: :unauthorized
        end
      end

      private

      def find_room
        @room = Room.find_by!(friendly_id: params[:friendly_id])
      end

      # Returns true if the room is accessible to all or if the access code is correct
      def authorize_access?
        @room.access_code.blank? || @room.access_code == params[:access_code]
      end
    end
  end
end
