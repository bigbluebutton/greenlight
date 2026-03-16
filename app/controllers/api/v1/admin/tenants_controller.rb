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
      class TenantsController < ApiController
        before_action do
          ensure_super_admin
        end

        # GET /api/v1/admin/tenants
        def index
          sort_config = config_sorting(allowed_columns: %w[name])

          tenants = Tenant.order(sort_config, created_at: :desc)&.search(params[:search])

          pagy, tenants = pagy(tenants)

          render_data data: tenants, meta: pagy_metadata(pagy), status: :ok
        end

        # POST /api/v1/admin/tenants
        def create
          name = tenant_params[:name]
          tenant = Tenant.new(name:, client_secret: tenant_params[:client_secret])

          if tenant.save
            TenantSetup.new(name).call
            render_data status: :created
          else
            render_error errors: tenant.errors.to_a, status: :bad_request
          end
        end

        # DELETE /api/v1/admin/tenants/:id
        def destroy
          tenant = Tenant.find(params[:id])

          if tenant.destroy
            delete_roles(tenant.name)
            delete_site_settings(tenant.name)
            delete_rooms_configs_options(tenant.name)
            render_data status: :ok
          else
            render_error errors: tenant.errors.to_a, status: :bad_request
          end
        end

        def cache; end

        def delete_roles(provider)
          Role.where(provider:).destroy_all
        end

        def delete_site_settings(provider)
          SiteSetting.where(provider:).destroy_all
        end

        def delete_rooms_configs_options(provider)
          RoomsConfiguration.where(provider:).destroy_all
        end

        def tenant_params
          params.require(:tenant).permit(:name, :client_secret)
        end
      end
    end
  end
end
