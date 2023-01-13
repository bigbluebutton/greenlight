# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SiteSettingsController, type: :controller do
  let(:user) { create(:user) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    sign_in_user(user)
  end

  describe '#index' do
    it 'calls SettingGetter and returns the value from it' do
      expect(SettingGetter).to receive(:new).with(setting_name: 'SettingName', provider: 'greenlight').and_call_original
      allow_any_instance_of(SettingGetter).to receive(:call).and_return('false')

      get :index, params: { names: 'SettingName' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']).to eq('false')
    end

    it 'calls SettingGetter and returns multiple values' do
      expect(SettingGetter).to receive(:new).with(setting_name: 'SettingName', provider: 'greenlight').and_call_original
      expect(SettingGetter).to receive(:new).with(setting_name: 'SettingName2', provider: 'greenlight').and_call_original
      allow_any_instance_of(SettingGetter).to receive(:call).and_return('false')

      get :index, params: { names: %w[SettingName SettingName2] }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['SettingName']).to eq('false')
      expect(JSON.parse(response.body)['data']['SettingName2']).to eq('false')
    end

    it 'returns forbidden if trying to access a forbidden setting' do
      get :index, params: { names: %w[SettingName RoleMapping] }

      expect(response).to have_http_status(:forbidden)
    end
  end
end
