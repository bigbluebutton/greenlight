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
    module Admin
      class RolePermissionsController < ApiController
        before_action do
          ensure_authorized('ManageRoles')
        end

        # GET /api/v1/admin/role_permissions
        # Returns a hash of all Role Permissions
        def index
          roles_permissions = RolePermission.joins(:permission)
                                            .where(role_id: params[:role_id])
                                            .pluck(:name, :value)
                                            .to_h

          render_data data: roles_permissions, status: :ok
        end

        # POST /api/v1/admin/role_permissions
        # Updates the permission for the specified role
        def update
          role_permission = RolePermission.joins(:permission).find_by(role_id: role_params[:role_id], permission: { name: role_params[:name] })

          return render_error status: :not_found unless role_permission
          return render_error status: :bad_request unless role_permission.update(value: role_params[:value].to_s)

          create_default_room # Create default room if 'CreateRoom' permission is enabled
          render_data status: :ok
        end

        private

        def role_params
          params.require(:role).permit(:role_id, :name, :value)
        end

        def create_default_room
          return unless role_params[:name] == 'CreateRoom' && role_params[:value] == true

          User.includes(:rooms)
              .with_provider(current_provider)
              .where(role_id: role_params[:role_id])
              .where(rooms: { id: nil }).find_in_batches do |group|
            group.each do |user|
              Room.create(name: t('room.new_room_name', username: user.name, locale: user.language), user_id: user.id)
            end
          end
        end
      end
    end
  end
end
