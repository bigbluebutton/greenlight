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
          # TODO: - ahmad: Add role check
        end

        # GET /api/v1/admin/tenants
        def index
          sort_config = config_sorting(allowed_columns: %w[name])

          tenants = Tenant.select(:id, :name, :client_secret)&.order(sort_config, created_at: :desc)&.search(params[:search])

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

        private

        def create_roles(provider)
          Role.create! [
            { name: 'Administrator', provider: },
            { name: 'User', provider: },
            { name: 'Guest', provider: }
          ]
        end

        def create_site_settings(provider)
          SiteSetting.create! [
            { setting: Setting.find_by(name: 'PrimaryColor'), value: '#467fcf', provider: },
            { setting: Setting.find_by(name: 'PrimaryColorLight'), value: '#e8eff9', provider: },
            { setting: Setting.find_by(name: 'PrimaryColorDark'), value: '#316cbe', provider: },
            { setting: Setting.find_by(name: 'BrandingImage'),
              value: ActionController::Base.helpers.image_path('bbb_logo.png'),
              provider: },
            { setting: Setting.find_by(name: 'Terms'), value: '', provider: },
            { setting: Setting.find_by(name: 'PrivacyPolicy'), value: '', provider: },
            { setting: Setting.find_by(name: 'RegistrationMethod'), value: SiteSetting::REGISTRATION_METHODS[:open], provider: },
            { setting: Setting.find_by(name: 'ShareRooms'), value: 'true', provider: },
            { setting: Setting.find_by(name: 'PreuploadPresentation'), value: 'true', provider: },
            { setting: Setting.find_by(name: 'RoleMapping'), value: '', provider: },
            { setting: Setting.find_by(name: 'DefaultRole'), provider:, value: 'User' }
          ]
        end

        def create_rooms_configs_options(provider)
          RoomsConfiguration.create! [
            { meeting_option: MeetingOption.find_by(name: 'record'), value: 'default_enabled', provider: },
            { meeting_option: MeetingOption.find_by(name: 'muteOnStart'), value: 'optional', provider: },
            { meeting_option: MeetingOption.find_by(name: 'guestPolicy'), value: 'optional', provider: },
            { meeting_option: MeetingOption.find_by(name: 'glAnyoneCanStart'), value: 'optional', provider: },
            { meeting_option: MeetingOption.find_by(name: 'glAnyoneJoinAsModerator'), value: 'optional', provider: },
            { meeting_option: MeetingOption.find_by(name: 'glRequireAuthentication'), value: 'optional', provider: },
            { meeting_option: MeetingOption.find_by(name: 'glViewerAccessCode'), value: 'optional', provider: },
            { meeting_option: MeetingOption.find_by(name: 'glModeratorAccessCode'), value: 'optional', provider: }
          ]
        end

        def create_role_permissions(provider)
          admin = Role.find_by(name: 'Administrator', provider:)
          user = Role.find_by(name: 'User', provider:)
          guest = Role.find_by(name: 'Guest', provider:)

          create_room = Permission.find_by(name: 'CreateRoom')
          manage_users = Permission.find_by(name: 'ManageUsers')
          manage_rooms = Permission.find_by(name: 'ManageRooms')
          manage_recordings = Permission.find_by(name: 'ManageRecordings')
          manage_site_settings = Permission.find_by(name: 'ManageSiteSettings')
          manage_roles = Permission.find_by(name: 'ManageRoles')
          shared_list = Permission.find_by(name: 'SharedList')
          can_record = Permission.find_by(name: 'CanRecord')
          room_limit = Permission.find_by(name: 'RoomLimit')

          RolePermission.create! [
            { role: admin, permission: create_room, value: 'true' },
            { role: admin, permission: manage_users, value: 'true' },
            { role: admin, permission: manage_rooms, value: 'true' },
            { role: admin, permission: manage_recordings, value: 'true' },
            { role: admin, permission: manage_site_settings, value: 'true' },
            { role: admin, permission: manage_roles, value: 'true' },
            { role: admin, permission: shared_list, value: 'true' },
            { role: admin, permission: can_record, value: 'true' },
            { role: admin, permission: room_limit, value: '100' },

            { role: user, permission: create_room, value: 'true' },
            { role: user, permission: manage_users, value: 'false' },
            { role: user, permission: manage_rooms, value: 'false' },
            { role: user, permission: manage_recordings, value: 'false' },
            { role: user, permission: manage_site_settings, value: 'false' },
            { role: user, permission: manage_roles, value: 'false' },
            { role: user, permission: shared_list, value: 'true' },
            { role: user, permission: can_record, value: 'true' },
            { role: user, permission: room_limit, value: '100' },

            { role: guest, permission: create_room, value: 'false' },
            { role: guest, permission: manage_users, value: 'false' },
            { role: guest, permission: manage_rooms, value: 'false' },
            { role: guest, permission: manage_recordings, value: 'false' },
            { role: guest, permission: manage_site_settings, value: 'false' },
            { role: guest, permission: manage_roles, value: 'false' },
            { role: guest, permission: shared_list, value: 'true' },
            { role: guest, permission: can_record, value: 'true' },
            { role: guest, permission: room_limit, value: '100' }
          ]
        end

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
