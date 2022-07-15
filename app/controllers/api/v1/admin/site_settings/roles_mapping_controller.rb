# frozen_string_literal: true

module Api
  module V1
    module Admin
      module SiteSettings
        class RolesMappingController < ApiController
          # GET /api/v1/admin/site_settings/roles_mapping.json
          # Expects: {}
          # Returns: { data: Array[serializable objects] , errors: Array[String] }
          # Does: Fetches and returns the list of roles mapping rules.

          def index
            roles_mapping_json = Setting.joins(:site_settings)
                                        .select(:value)
                                        .find_by(name: 'RoleMapping', site_settings: { provider: 'greenlight' })&.value

            render_json data: JSON.parse(roles_mapping_json)
          end

          # POST /api/v1/admin/site_settings/roles_mapping/update.json
          # Expects: {}
          # Returns: { data: Array[serializable objects] , errors: Array[String] }
          # Does: Updates the list of roles mapping rules.

          def update_rules
            current_roles_mapping = SiteSetting.joins(:setting).find_by(provider: 'greenlight', setting: { name: 'RoleMapping' })

            return render_error status: :internal_server_error unless current_roles_mapping

            new_roles_mapping_json = roles_map_params.to_json

            return render_error status: :bad_request unless current_roles_mapping.update value: new_roles_mapping_json

            render_json data: JSON.parse(new_roles_mapping_json)
          end

          private

          def roles_map_params
            params.require(:site_settings).permit(roles_map: [%i[name suffix]])
          end
        end
      end
    end
  end
end
