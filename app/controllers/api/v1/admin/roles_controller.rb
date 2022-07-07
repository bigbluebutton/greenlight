# frozen_string_literal: true

module Api
  module V1
    module Admin
      class RolesController < ApiController
        # POST /api/v1/admin/roles.json
        # Expects: {}
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Fetches and returns the list of roles.

        def index
          sort_config = config_sorting(allowed_columns: %w[name])

          roles = Role.select(:id, :name, :color)&.order(sort_config)&.search(params[:search])
          render_json data: roles
        end

        # POST /api/v1/roles.json
        # Expects: { role: {:name, :color} }
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Creates a role.

        def create
          role = Role.new role_params

          return render_error errors: role.errors.to_a, status: :bad_request unless role.save

          render_json status: :created
        end

        private

        def role_params
          params.require(:role).permit(:name)
        end
      end
    end
  end
end
