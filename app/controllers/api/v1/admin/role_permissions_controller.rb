# frozen_string_literal: true

module Api
  module V1
    module Admin
      class RolePermissionsController < ApiController
        before_action do
          ensure_authorized('ManageRoles')
        end
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

          create_default_room
          render_data status: :ok
        end

        private

        def role_params
          params.require(:role).permit(:role_id, :name, :value)
        end

        def create_default_room
          return unless role_params[:name] == 'CreateRoom' && role_params[:value] == true

          User.includes(:rooms).where(role_id: role_params[:role_id]).where(rooms: { id: nil }).find_in_batches do |group|
            group.each do |user|
              Room.create(name: "#{user.name}'s Room", user_id: user.id)
            end
          end
        end
      end
    end
  end
end
