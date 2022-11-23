# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::AdminsController, type: :controller do
  let(:user) { create(:user) }
  let(:provider) { 'bigbluebutton' }

  before do
    request.headers['ACCEPT'] = 'application/json'
    sign_in_user(user)
    create_settings_permissions_meetingoptions
  end

  describe 'provider' do
    it 'creates the default roles for the provider' do
      post :provider, params: { provider: }

      expect(Role.exists?(name: 'Administrator', provider:)).to be true
      expect(Role.exists?(name: 'User', provider:)).to be true
      expect(Role.exists?(name: 'Guest', provider:)).to be true
    end

    it 'creates the default SiteSettings for the provider' do
      post :provider, params: { provider: }

      settings = Setting.all
      settings.each do |setting|
        expect(SiteSetting.exists?(setting:, provider:)).to be true
      end
    end

    it 'creates the default RoomsConfiguration for the provider' do
      post :provider, params: { provider: }

      options = MeetingOption.all
      options.each do |option|
        expect(RoomsConfiguration.exists?(meeting_option: option, provider:)).to be true
      end
    end

    it 'creates the default RolePermissions for the provider' do
      post :provider, params: { provider: }

      roles = Role.where(provider:)
      permissions = Permission.all

      permissions.each do |permission|
        roles.each do |role|
          expect(RolePermission.exists?(role:, permission:)).to be true
        end
      end
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
    Setting.find_or_create_by(name: 'RegistrationMethod')
    Setting.find_or_create_by(name: 'ShareRooms')
    Setting.find_or_create_by(name: 'PreuploadPresentation')
    Setting.find_or_create_by(name: 'RoleMapping')
    Setting.find_or_create_by(name: 'DefaultRole')

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
end
