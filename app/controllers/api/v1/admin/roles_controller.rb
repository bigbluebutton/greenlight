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
        # Expects: {}
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Fetches and returns the list of roles.

        def index
          sort_config = config_sorting(allowed_columns: %w[name])

          roles = Role.with_provider(current_provider)&.order(sort_config)&.search(params[:search])

          render_data data: roles, status: :ok
        end

        # GET /api/v1/admin/roles/:role_id.json
        # Expects: {}
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Fetches and returns a role data.

        def show
          render_data data: @role, status: :ok
        end

        # POST /api/v1/roles.json
        # Expects: { role: {:name, :color} }
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Creates a role.

        def create
          role = Role.new(name: role_params[:name], provider: current_provider)

          return render_error errors: role.errors.to_a, status: :bad_request unless role.save

          render_data status: :created
        end

        # POST /api/v1/:id/roles.json
        # Expects: { role: {:name, :color} }
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Updates a role.

        def update
          return render_error errors: @role.errors.to_a, status: :bad_request unless @role.update role_params

          render_data status: :ok
        end

        # DELETE /api/v1/admin/roles.json
        # Expects: {}
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Deletes a role.
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
