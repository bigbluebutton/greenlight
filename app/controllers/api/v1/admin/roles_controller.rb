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
      class RolesController < ApiController
        before_action :find_role, only: %i[update show destroy]
        before_action only: %i[index] do
          ensure_authorized(%w[ManageUsers ManageRoles])
        end
        before_action except: %i[index] do
          ensure_authorized('ManageRoles')
        end

        # POST /api/v1/admin/roles.json
        # Fetches and returns the list of roles
        def index
          sort_config = config_sorting(allowed_columns: %w[name])

          roles = Role.with_provider(current_provider)&.order(sort_config)&.search(params[:search])

          render_data data: roles, status: :ok
        end

        # GET /api/v1/admin/roles/:role_id.json
        # Fetches and returns a role's data
        def show
          render_data data: @role, status: :ok
        end

        # POST /api/v1/roles.json
        # Creates a role
        def create
          role = Role.new(name: role_params[:name], provider: current_provider)

          return render_error errors: role.errors.to_a, status: :bad_request unless role.save

          render_data status: :created
        end

        # POST /api/v1/:id/roles.json
        # Updates a role
        def update
          return render_error errors: @role.errors.to_a, status: :bad_request unless @role.update role_params

          render_data status: :ok
        end

        # DELETE /api/v1/admin/roles.json
        # Deletes a role
        def destroy
          undeletable_roles = %w[User Administrator Guest]
          return render_error errors: @role.errors.to_a, status: :method_not_allowed if undeletable_roles.include?(@role.name)

          @role.destroy!

          render_data status: :ok
        end

        private

        def role_params
          params.require(:role).permit(:name)
        end

        def find_role
          @role = Role.find params[:id]
        end
      end
    end
  end
end
