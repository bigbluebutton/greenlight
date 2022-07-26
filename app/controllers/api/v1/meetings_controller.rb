# frozen_string_literal: true

module Api
  module V1
    class MeetingsController < ApiController
      before_action :find_room, only: %i[start join]

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

        render_data data: {
          join_url: BigBlueButtonApi.new.join_meeting(room: @room, name: current_user.name, role: 'Moderator')
        }, status: :created
      end

      # GET /api/v1/meetings/:friendly_id/join.json
      def join
        data = {
          status: BigBlueButtonApi.new.meeting_running?(room: @room)
        }

        if authorized_as_viewer? || authorized_as_moderator?
          bbb_role = authorized_as_moderator? ? 'Moderator' : 'Viewer'

          data[:joinUrl] = BigBlueButtonApi.new.join_meeting(room: @room, name: params[:name], role: bbb_role) if data[:status]
          render_data data:, status: :ok
        else
          render_error status: :unauthorized
        end
      end

      private

      def find_room
        @room = Room.find_by!(friendly_id: params[:friendly_id])
      end

      def authorized_as_viewer?
        (params[:access_code].blank? && @room.viewer_access_code.blank?) ||
          (params[:access_code].present? && @room.viewer_access_code == params[:access_code])
      end

      def authorized_as_moderator?
        (params[:access_code].present? && @room.moderator_access_code == params[:access_code]) || @room.anyone_joins_as_moderator?
      end
    end
  end
end
