# frozen_string_literal: true

module Api
  module V1
    module Admin
      class RolePermissionsController < ApiController
        def index
          roles_permissions = RolePermission.joins(:permission)
                                            .where(role_id: params[:role_id])
                                            .pluck(:name, :value)
                                            .to_h

          render_data data: roles_permissions, status: :ok
        end

        def update
          role_permission = RolePermission.joins(:permission).find_by(role_id: role_params[:role_id], permission: { name: role_params[:name] })

          return render_error status: :not_found unless role_permission
          return render_error status: :bad_request unless role_permission.update(value: role_params[:value].to_s)

          render_data status: :ok
        end

        private

        def role_params
          params.require(:role).permit(:role_id, :name, :value)
        end
      end
    end
  end
end
