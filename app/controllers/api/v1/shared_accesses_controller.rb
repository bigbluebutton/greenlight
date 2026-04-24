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
    class SharedAccessesController < ApiController
      before_action :find_room

      before_action only: %i[create destroy shareable_users] do
        ensure_authorized('ManageRooms', friendly_id: params[:friendly_id])
      end
      before_action only: %i[show unshare_room] do
        ensure_authorized(%w[ManageRooms SharedRoom], friendly_id: params[:friendly_id])
      end

      # GET /api/v1/shared_accesses/:friendly_id.json
      # Returns a list of all of the room's shared users
      def show
        render_data data: @room.shared_users.search(params[:search]), serializer: SharedAccessSerializer, status: :ok
      end

      # POST /api/v1/shared_accesses.json
      # Shares the room with all of the specified users
      def create
        shared_users_ids = Array(params[:shared_users])
        # Only allow sharing with users of current tenant
        filtered_ids = User.with_provider(current_provider).where(id: shared_users_ids).pluck(:id)

        filtered_ids.each do |shared_user_id|
          SharedAccess.create(user_id: shared_user_id, room_id: @room.id)
        end

        render_data status: :ok
      end

      # DELETE /api/v1/shared_accesses/friendly_id.json
      # Unshares a room with the specified user
      def destroy
        SharedAccess.delete_by(user_id: params[:user_id], room_id: @room.id)

        render_data status: :ok
      end

      # DELETE /api/v1/shared_accesses/friendly_id.json
      # Similar to the destroy action
      # Unshares a room that is shared with the current user as a the current user
      def unshare_room
        SharedAccess.delete_by(user_id: current_user.id, room_id: @room.id)

        render_data status: :ok
      end

      # GET /api/v1/shared_accesses/friendly_id/shareable_users.json
      # Returns a list of users with whom a room can be shared with (based on role permissions)
      def shareable_users
        return render_data data: [], status: :ok unless params[:search].present? && params[:search].length >= 3

        # role_id of roles that have SharedList permission set to true
        role_ids = RolePermission.joins(:permission).where(permission: { name: 'SharedList' }).where(value: 'true').pluck(:role_id)

        # Can't share the room if it's already shared or it's the room owner
        shareable_users = User.with_attached_avatar
                              .with_provider(current_provider)
                              .where.not(id: [@room.shared_users.pluck(:id) << @room.user_id])
                              .where(role_id: [role_ids])
                              .shared_access_search(params[:search])
        render_data data: shareable_users, serializer: SharedAccessSerializer, status: :ok
      end

      private

      def find_room
        @room = Room.find_by(friendly_id: params[:friendly_id])
      end
    end
  end
end
