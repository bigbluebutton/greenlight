# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SiteSettingsController, type: :controller do
  before do
    request.headers['ACCEPT'] = 'application/json'
  end

  describe 'site_settings#index' do
    it 'returns a hash of site settings :name => :value' do
      settings = [
        create(:setting, name: 'Leonardo'), create(:setting, name: 'Michelangelo'),
        create(:setting, name: 'Donatello'), create(:setting, name: 'Raphael')
      ]

      create(:site_setting, setting: settings[0], value: 'Blue', provider: 'greenlight')
      create(:site_setting, setting: settings[1], value: 'Orange', provider: 'greenlight')
      create(:site_setting, setting: settings[2], value: 'Purple', provider: 'greenlight')
      create(:site_setting, setting: settings[3], value: 'Red', provider: 'greenlight')

      get :index

      expect(JSON.parse(response.body)['data']).to eq({
                                                        'Leonardo' => 'Blue',
                                                        'Michelangelo' => 'Orange',
                                                        'Donatello' => 'Purple',
                                                        'Raphael' => 'Red'
                                                      })
      expect(response).to have_http_status(:ok)
    end

    it 'returns :internal_server_error if there\'s no site settings for the provider' do
      create(:site_setting, provider: 'BROVIDER')

      get :index

      expect(response).to have_http_status(:internal_server_error)
    end

    it 'JSON parses "RoleMapping"' do
      value = [{ 'foo' => 'foo' }, { 'bar' => 'bar' }, [{ 'zoo' => 'zoo' }]]
      setting = create(:setting, name: 'RoleMapping')
      create(:site_setting, setting:, provider: 'greenlight', value: value.to_json)

      get :index

      expect(JSON.parse(response.body)['data']['RoleMapping']).to eq(value)
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#show' do
    it 'calls SettingGetter and returns the value from it' do
      expect(SettingGetter).to receive(:new).with(setting_name: 'SettingName', provider: 'greenlight').and_call_original
      allow_any_instance_of(SettingGetter).to receive(:call).and_return({ 'value' => 'false' })

      get :show, params: { name: 'SettingName' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['value']).to eq('false')
    end
  end
end
