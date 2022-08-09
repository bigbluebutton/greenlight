# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SiteSettingsController, type: :controller do
  let(:user) { create(:user) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user.id
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
