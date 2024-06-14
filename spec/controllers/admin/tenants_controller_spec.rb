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

require 'rails_helper'

RSpec.describe Api::V1::Admin::TenantsController, type: :controller do
  let(:user) { create(:user, :with_super_admin) }
  let(:valid_tenant_params) do
    {
      name: 'new_provider',
      client_secret: 'abcdefg123456789'
    }
  end

  before do
    request.headers['ACCEPT'] = 'application/json'
    sign_in_user(user)
    create_settings_permissions_meetingoptions
  end

  describe 'creates' do
    it 'creates the default roles for the provider' do
      post :create, params: { tenant: valid_tenant_params }

      expect(Role.exists?(name: 'Administrator', provider: valid_tenant_params[:name])).to be true
      expect(Role.exists?(name: 'User', provider: valid_tenant_params[:name])).to be true
      expect(Role.exists?(name: 'Guest', provider: valid_tenant_params[:name])).to be true
    end

    it 'creates the default SiteSettings for the provider' do
      post :create, params: { tenant: valid_tenant_params }

      settings = Setting.all
      settings.each do |setting|
        expect(SiteSetting.exists?(setting:, provider: valid_tenant_params[:name])).to be true
      end
    end

    it 'creates the default RoomsConfiguration for the provider' do
      post :create, params: { tenant: valid_tenant_params }

      options = MeetingOption.all
      options.each do |option|
        expect(RoomsConfiguration.exists?(meeting_option: option, provider: valid_tenant_params[:name])).to be true
      end
    end

    it 'creates the default RolePermissions for the provider' do
      post :create, params: { tenant: valid_tenant_params }

      roles = Role.where(provider: valid_tenant_params[:name])
      permissions = Permission.all

      permissions.each do |permission|
        roles.each do |role|
          expect(RolePermission.exists?(role:, permission:)).to be true
        end
      end
    end
  end

  describe 'destroy' do
    let!(:og_tenant) { create(:tenant) }
    let!(:new_tenant) { create(:tenant) }

    before do
      create_roles([og_tenant.name, new_tenant.name])
      create_site_settings([og_tenant.name, new_tenant.name])
      create_room_configs_options([og_tenant.name, new_tenant.name])
      create_role_permissions([og_tenant.name, new_tenant.name])
    end

    it 'deletes the tenant' do
      delete :destroy, params: { id: og_tenant.id }
      expect(Tenant.exists?(name: og_tenant.name)).to be false
    end

    it 'does not delete the other tenants' do
      delete :destroy, params: { id: og_tenant.id }
      expect(Tenant.exists?(name: new_tenant.name)).to be true
    end

    it 'deletes the roles for the tenant' do
      delete :destroy, params: { id: og_tenant.id }
      expect(Role.exists?(provider: og_tenant.name)).to be false
    end

    it 'does not delete the roles for the other tenants' do
      delete :destroy, params: { id: og_tenant.id }
      expect(Role.exists?(provider: new_tenant.name)).to be true
    end

    it 'deletes the site settings for the tenant' do
      delete :destroy, params: { id: og_tenant.id }
      expect(SiteSetting.exists?(provider: og_tenant.name)).to be false
    end

    it 'does not delete the site settings for the other tenants' do
      delete :destroy, params: { id: og_tenant.id }
      expect(SiteSetting.exists?(provider: new_tenant.name)).to be true
    end

    it 'deletes the rooms configuration for the tenant' do
      delete :destroy, params: { id: og_tenant.id }
      expect(RoomsConfiguration.exists?(provider: og_tenant.name)).to be false
    end

    it 'does not delete the rooms configuration for the other tenants' do
      delete :destroy, params: { id: og_tenant.id }
      expect(RoomsConfiguration.exists?(provider: new_tenant.name)).to be true
    end
  end

  private

  def create_settings_permissions_meetingoptions
    # Required to avoid duplicates
    Setting.find_or_create_by(name: 'PrimaryColor')
    Setting.find_or_create_by(name: 'PrimaryColorLight')
    Setting.find_or_create_by(name: 'PrimaryColorDark')
    Setting.find_or_create_by(name: 'BrandingImage')
    Setting.find_or_create_by(name: 'Terms')
    Setting.find_or_create_by(name: 'PrivacyPolicy')
    Setting.find_or_create_by(name: 'HelpCenter')
    Setting.find_or_create_by(name: 'RegistrationMethod')
    Setting.find_or_create_by(name: 'ShareRooms')
    Setting.find_or_create_by(name: 'PreuploadPresentation')
    Setting.find_or_create_by(name: 'RoleMapping')
    Setting.find_or_create_by(name: 'DefaultRole')
    Setting.find_or_create_by(name: 'DefaultRecordingVisibility')
    Setting.find_or_create_by(name: 'HelpCenter')
    Setting.find_or_create_by(name: 'Maintenance')
    Setting.find_or_create_by(name: 'SessionTimeout')

    Permission.find_or_create_by(name: 'CreateRoom')
    Permission.find_or_create_by(name: 'ManageUsers')
    Permission.find_or_create_by(name: 'ManageRooms')
    Permission.find_or_create_by(name: 'ManageRecordings')
    Permission.find_or_create_by(name: 'ManageSiteSettings')
    Permission.find_or_create_by(name: 'ManageRoles')
    Permission.find_or_create_by(name: 'SharedList')
    Permission.find_or_create_by(name: 'CanRecord')
    Permission.find_or_create_by(name: 'RoomLimit')

    MeetingOption.find_or_create_by(name: 'record', default_value: 'false')
    MeetingOption.find_or_create_by(name: 'muteOnStart', default_value: 'false')
    MeetingOption.find_or_create_by(name: 'guestPolicy', default_value: 'ALWAYS_ACCEPT')
    MeetingOption.find_or_create_by(name: 'glAnyoneCanStart', default_value: 'false')
    MeetingOption.find_or_create_by(name: 'glAnyoneJoinAsModerator', default_value: 'false')
    MeetingOption.find_or_create_by(name: 'glRequireAuthentication', default_value: 'false')
    MeetingOption.find_or_create_by(name: 'glModeratorAccessCode', default_value: '')
    MeetingOption.find_or_create_by(name: 'glViewerAccessCode', default_value: '')
  end

  def create_roles(providers)
    providers.each do |provider|
      Role.create! [
        { name: 'Administrator', provider: },
        { name: 'User', provider: },
        { name: 'Guest', provider: }
      ]
    end
  end

  def create_site_settings(providers)
    providers.each do |provider|
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
  end

  def create_room_configs_options(providers)
    providers.each do |provider|
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
  end

  def create_role_permissions(providers)
    providers.each do |provider|
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
  end
end
