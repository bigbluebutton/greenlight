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
        if authorized_as_viewer? || authorized_as_moderator?
          if authorized_as_moderator?
            bbb_role = 'Moderator'
          elsif authorized_as_viewer?
            bbb_role = 'Viewer'
          end
          render_json data: BigBlueButtonApi.new.join_meeting(room: @room, name: params[:name], role: bbb_role), status: :ok
        else
          render_json status: :unauthorized
        end
      end

      # GET /api/v1/meetings/:friendly_id/status.json
      def status
        data = {
          status: BigBlueButtonApi.new.meeting_running?(room: @room)
        }

        if authorized_as_viewer? || authorized_as_moderator?
          if authorized_as_moderator?
            bbb_role = 'Moderator'
          elsif authorized_as_viewer?
            bbb_role = 'Viewer'
          end
          data[:joinUrl] = BigBlueButtonApi.new.join_meeting(room: @room, name: params[:name], role: bbb_role) if data[:status]
          render_json data:, status: :ok
        else
          render_json status: :unauthorized
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
        params[:access_code].present? && @room.moderator_access_code == params[:access_code]
      end
    end
  end
end
