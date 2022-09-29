# frozen_string_literal: true

module Api
  module V1
    class MeetingsController < ApiController
      before_action :find_room, only: %i[start status running]
      skip_before_action :ensure_authenticated, only: %i[status]
      before_action only: %i[start running] do
        ensure_authorized('ManageRooms', friendly_id: params[:friendly_id])
      end

      # POST /api/v1/meetings/:friendly_id/start.json
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Starts the Room meeting and joins in the meeting starter.
      def start
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

        render_data data: BigBlueButtonApi.new.join_meeting(
          room: @room,
          name: current_user.name,
          avatar_url: current_user.avatar.attached? ? url_for(current_user.avatar) : nil,
          role: 'Moderator'
        ), status: :created
      end

      # POST /api/v1/meetings/:friendly_id/status.json
      def status
        settings = RoomSettingsGetter.new(
          room_id: @room.id,
          provider: current_provider,
          current_user:,
          show_codes: true,
          settings: %w[glRequireAuthentication glViewerAccessCode glModeratorAccessCode glAnyoneCanStart]
        ).call

        return render_error status: :unauthorized if !current_user && settings['glRequireAuthentication'] == 'true'

        bbb_role = infer_bbb_role(mod_code: settings['glModeratorAccessCode'], viewer_code: settings['glViewerAccessCode'])

        return render_error status: :forbidden if bbb_role.nil?

        data = {
          status: BigBlueButtonApi.new.meeting_running?(room: @room)
        }

        if !data[:status] && settings['glAnyoneCanStart'] == 'true' # Meeting isnt running and anyoneCanStart setting is enabled
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

          data[:status] = true
        end

        if data[:status]
          data[:joinUrl] = BigBlueButtonApi.new.join_meeting(
            room: @room,
            name: current_user ? current_user.name : params[:name],
            avatar_url: current_user&.avatar&.attached? ? url_for(current_user.avatar) : nil,
            role: bbb_role
          )
        end

        render_data data:, status: :ok
      end

      # Returns a bool if a meeting is running or not
      # GET /api/v1/meetings/:friendly_id/running.json
      def running
        render_data data: BigBlueButtonApi.new.meeting_running?(room: @room), status: :ok
      end

      private

      def find_room
        @room = Room.find_by!(friendly_id: params[:friendly_id])
      end

      def presentation_url
        url_for(@room.presentation).gsub('&', '%26') if @room.presentation.attached?
      end

      def authorized_as_viewer?(access_code:)
        return true if access_code.blank?

        access_code == params[:access_code]
      end

      def authorized_as_moderator?(access_code:)
        (params[:access_code].present? && access_code == params[:access_code]) || @room.anyone_joins_as_moderator?
      end

      def infer_bbb_role(mod_code:, viewer_code:)
        # TODO: Handle access code circumventing when 'anyone_joins_as_moderator?' is true.

        if authorized_as_moderator?(access_code: mod_code)
          'Moderator'
        elsif authorized_as_viewer?(access_code: viewer_code)
          'Viewer'
        end
      end
    end
  end
end
