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
      class UsersController < ApiController
        before_action do
          ensure_authorized('ManageUsers')
        end

        # GET /api/v1/admin/users/:id.json
        # Updates the specified user's status
        def update
          user = User.find(params[:id])

          if user.update(user_params)
            render_data status: :ok
          else
            render_error errors: user.errors.to_a
          end
        end

        # GET /api/v1/admin/users/user_roles.json
        # Returns the list of roles that the current user can assign to other users
        def user_roles
          # Returns the permissions that the current user role has
          current_user_permission_ids = current_user.role.role_permissions.where(value: 'true').pluck(:permission_id)

          # Returns the roles that have role permissions that the current user role does not have
          ineligible_role_permission_ids = RolePermission.joins(:role)
                                                         .where('role.provider': current_provider)
                                                         .where(role_permissions: { value: 'true' })
                                                         .where.not(role_permissions: { permission_id: current_user_permission_ids })
                                                         .select(:role_id)

          # Returns the roles that DO NOT have role permissions that the current user role DOES NOT have
          eligible_roles = Role.with_provider(current_provider)
                               .includes(:role_permissions)
                               .where.not(id: ineligible_role_permission_ids)

          render_data data: eligible_roles, status: :ok
        end

        # GET /api/v1/admin/users/pending.json
        # Fetches the list of all users in the pending state
        def pending
          pending_users = User.includes(:role)
                              .with_provider(current_provider)
                              .where(status: 'pending')
                              .search(params[:search])

          pagy, pending_users = pagy(pending_users)

          render_data data: pending_users, meta: pagy_metadata(pagy), serializer: UserSerializer, status: :ok
        end

        # GET /api/v1/admin/users/verified.json
        # Fetches all active users
        def verified
          sort_config = config_sorting(allowed_columns: %w[name roles.name])

          users = User.includes(:role)
                      .with_provider(current_provider)
                      .where(status: 'active')
                      .with_attached_avatar
                      .order(sort_config, created_at: :desc)&.search(params[:search])

          pagy, users = pagy(users)

          render_data data: users, meta: pagy_metadata(pagy), serializer: UserSerializer, status: :ok
        end

        # GET /api/v1/admin/users/banned.json
        # Fetches all banned users
        def banned
          users = User.includes(:role)
                      .with_provider(current_provider)
                      .with_attached_avatar
                      .where(status: :banned)
                      .order(created_at: :desc)&.search(params[:search])

          pagy, users = pagy(users)

          render_data data: users, meta: pagy_metadata(pagy), serializer: UserSerializer, status: :ok
        end

        private

        def user_params
          params.require(:user).permit(:status)
        end
      end
    end
  end
end
