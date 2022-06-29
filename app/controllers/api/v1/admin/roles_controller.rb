# frozen_string_literal: true

module Api
  module V1
    module Admin
      class RolesController < ApiController
        skip_before_action :verify_authenticity_token

        # POST /api/v1/admin/roles.json
        # Expects: {}
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Fetches and returns the list of roles.

        def index
          sort_config = config_sorting(allowed_columns: %w[name])

          roles = Role.select(:id, :name, :color)&.order(sort_config)&.search(params[:search])
          render_json data: roles
        end
      end
    end
  end
end
