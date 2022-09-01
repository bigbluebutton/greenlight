# frozen_string_literal: true

module Api
  module V1
    class MeetingsController < ApiController
      before_action :find_room, only: %i[start status]
      skip_before_action :ensure_authenticated, only: %i[status]
      before_action only: %i[start] do
        ensure_authorized('ManageRooms', friendly_id: params[:friendly_id])
      end

      # POST /api/v1/meetings/:friendly_id/start.json
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Starts the Room meeting and joins in the meeting starter.
      def start
        presentation_url = (url_for(@room.presentation).gsub('&', '%26') if @room.presentation.attached?)

        begin
          MeetingStarter.new(
            room: @room,
            logout_url: request.referer,
            presentation_url:,
            meeting_ended: meeting_ended_url,
            recording_ready: recording_ready_url,
            current_user:,
            provider: current_provider
          ).call
        rescue BigBlueButton::BigBlueButtonException => e
          return render_error status: :bad_request unless e.key == 'idNotUnique'
        end

        render_data data: BigBlueButtonApi.new.join_meeting(room: @room, name: current_user.name, role: 'Moderator'), status: :created
      end

      # POST /api/v1/meetings/:friendly_id/status.json
      def status
        bbb_role = infer_bbb_role(room_id: @room.id)

        return render_error status: :forbidden if bbb_role.nil?

        data = {
          status: BigBlueButtonApi.new.meeting_running?(room: @room)
        }

        data[:joinUrl] = BigBlueButtonApi.new.join_meeting(room: @room, name: params[:name], role: bbb_role) if data[:status]
        render_data data:, status: :ok
      end

      private

      def find_room
        @room = Room.find_by!(friendly_id: params[:friendly_id])
      end

      def authorized_as_viewer?(access_code:)
        (params[:access_code].blank? && access_code.blank?) ||
          (params[:access_code].present? && access_code == params[:access_code])
      end

      def authorized_as_moderator?(access_code:)
        (params[:access_code].present? && access_code == params[:access_code]) || @room.anyone_joins_as_moderator?
      end

      def infer_bbb_role(room_id:)
        # TODO: Handle access code circumventing when 'anyone_joins_as_moderator?' is true.
        room_access_codes = RoomSettingsGetter.new(room_id:, provider: current_provider, current_user:, show_codes: true,
                                                   settings: %w[glViewerAccessCode glModeratorAccessCode]).call

        if authorized_as_moderator?(access_code: room_access_codes['glModeratorAccessCode'])
          'Moderator'
        elsif authorized_as_viewer?(access_code: room_access_codes['glViewerAccessCode'])
          'Viewer'
        end
      end
    end
  end
end
