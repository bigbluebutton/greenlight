# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::SiteSettingsController, type: :controller do
  before { request.headers['ACCEPT'] = 'application/json' }

  describe 'site_settings#update' do
    it 'updates the site setting :value' do
      setting = create(:setting, name: 'Setting')
      site_setting = create(:site_setting, setting:, value: 'OLD', provider: 'greenlight')

      put :update, params: { name: 'Setting', site_setting: { value: 'NEW' } }

      expect(response).to have_http_status(:ok)
      expect(site_setting.reload.value).to eq('NEW')
    end

    it 'updates the site setting :value with a json stringified version for "RoleMapping"' do
      setting = create(:setting, name: 'RoleMapping')
      site_setting = create(:site_setting, setting:, value: '[]', provider: 'greenlight')

      value = { 'foo' => 'foo', 'bar' => 'bar', 'zoo' => 'zoo' }

      put :update, params: { name: 'RoleMapping', site_setting: { value: } }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(site_setting.reload.value)).to eq(value)
    end

    it 'returns :not_found for invalid :name' do
      put :update, params: { name: 'Unkown', site_setting: { value: 'GOOD' } }

      expect(response).to have_http_status(:not_found)
    end

    it 'returns :bad_request for invalid params' do
      setting = create(:setting, name: 'Setting')
      create(:site_setting, setting:, value: 'OLD', provider: 'greenlight')

      put :update, params: { name: 'Setting', not_site_setting: { not_value: 'BAD' } }

      expect(response).to have_http_status(:bad_request)
    end
  end
end
