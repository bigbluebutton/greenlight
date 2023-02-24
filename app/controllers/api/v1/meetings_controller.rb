# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

module Api
  module V1
    class MeetingsController < ApiController
      before_action :find_room, only: %i[start status running]
      skip_before_action :ensure_authenticated, only: %i[status]
      before_action only: %i[start running] do
        ensure_authorized(%w[ManageRooms SharedRoom], friendly_id: params[:friendly_id])
      end

      # POST /api/v1/meetings/:friendly_id/start.json
      # Starts a BigBlueButton meetings and joins in the meeting starter
      def start
        begin
          MeetingStarter.new(room: @room, base_url: root_url, current_user:).call
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
      # Checks if the meeting is running and either returns that value, or starts the meeting (if glAnyoneCanStart)
      # then joins the meeting starter into the BigBlueButton meeting
      def status
        settings = RoomSettingsGetter.new(
          room_id: @room.id,
          provider: current_provider,
          current_user:,
          show_codes: true,
          settings: %w[glRequireAuthentication glViewerAccessCode glModeratorAccessCode glAnyoneCanStart glAnyoneJoinAsModerator]
        ).call

        return render_error status: :unauthorized if !current_user && settings['glRequireAuthentication'] == 'true'

        bbb_role = infer_bbb_role(mod_code: settings['glModeratorAccessCode'],
                                  viewer_code: settings['glViewerAccessCode'],
                                  anyone_join_as_mod: settings['glAnyoneJoinAsModerator'] == 'true')

        return render_error status: :forbidden if bbb_role.nil?

        data = {
          status: BigBlueButtonApi.new.meeting_running?(room: @room)
        }

        if !data[:status] && settings['glAnyoneCanStart'] == 'true' # Meeting isnt running and anyoneCanStart setting is enabled
          begin
            MeetingStarter.new(room: @room, base_url: root_url, current_user:).call
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

      # GET /api/v1/meetings/:friendly_id/running.json
      # Returns whether the meeting is running in BigBlueButton or not
      def running
        render_data data: BigBlueButtonApi.new.meeting_running?(room: @room), status: :ok
      end

      private

      def find_room
        @room = Room.find_by!(friendly_id: params[:friendly_id])
      end

      def authorized_as_viewer?(viewer_code:)
        return true if viewer_code.blank? && params[:access_code].blank?

        access_code_validator(access_code: viewer_code)
      end

      # Five scenarios where a user is authorized to join a BBB meeting as a moderator:
      # The user joins
      # 1. its own room
      # 2. a shared room
      # 3. a room that requires a moderator access code and the access code input is correct
      # 4. a room that has the AnyoneJoinAsModerator setting enabled and does not require an access code
      # 5. a room that has the AnyoneJoinAsModerator setting enabled and requires a moderator or a viewer access code
      #    and the access code input correspond to either
      def authorized_as_moderator?(mod_code:, viewer_code:, anyone_join_as_mod:)
        @room.user_id == current_user&.id ||
          current_user&.shared_rooms&.include?(@room) ||
          access_code_validator(access_code: mod_code) ||
          (anyone_join_as_mod && viewer_code.blank? && mod_code.blank?) ||
          (anyone_join_as_mod && (access_code_validator(access_code: mod_code) || access_code_validator(access_code: viewer_code)))
      end

      def access_code_validator(access_code:)
        access_code.present? && params[:access_code].present? && access_code == params[:access_code]
      end

      def infer_bbb_role(mod_code:, viewer_code:, anyone_join_as_mod:)
        if authorized_as_moderator?(mod_code:, viewer_code:, anyone_join_as_mod:)
          'Moderator'
        elsif authorized_as_viewer?(viewer_code:) && !anyone_join_as_mod
          'Viewer'
        end
      end
    end
  end
end
