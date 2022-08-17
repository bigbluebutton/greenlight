# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::SiteSettingsController, type: :controller do
  let(:manage_site_settings_role) { create(:role) }
  let(:user) { create(:user, role: manage_site_settings_role) }
  let(:manage_site_settings_permission) { create(:permission, name: 'ManageSiteSettings') }
  let!(:manage_site_settings_role_permission) do
    create(:role_permission,
           role: manage_site_settings_role,
           permission: manage_site_settings_permission,
           value: 'true')
  end

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user.id
  end

  describe '#index' do
    # TODO: - Need to find way to test using returned hash from index
    it 'returns all the SiteSettings' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    context 'user without ManageSiteSettings permission' do
      before do
        manage_site_settings_role_permission.update!(value: 'false')
      end

      it 'cant return all the SiteSettings' do
        get :index
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe '#update' do
    it 'updates the value of SiteSetting' do
      setting = create(:setting, name: 'ShareRooms')
      site_setting = create(:site_setting, setting:, value: false)
      get :update, params: { name: 'ShareRooms', site_setting: { value: true } }
      expect(response).to have_http_status(:ok)
      expect(site_setting.reload.value).to eq('true')
    end

    context 'user without ManageSiteSettings permission' do
      before do
        manage_site_settings_role_permission.update!(value: 'false')
      end

      it 'cant update the value of SiteSetting' do
        get :update, params: { name: 'ShareRooms', site_setting: { value: true } }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
