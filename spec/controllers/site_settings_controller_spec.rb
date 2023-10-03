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
      expect(response.parsed_body['data']).to eq('false')
    end

    it 'calls SettingGetter and returns multiple values' do
      expect(SettingGetter).to receive(:new).with(setting_name: %w[Uno Dos Tres], provider: 'greenlight').and_call_original
      allow_any_instance_of(SettingGetter).to receive(:call).and_return({ 'Uno' => 1, 'Dos' => 2, 'Tres' => 3 })

      get :index, params: { names: %w[Uno Dos Tres] }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data']).to eq({ 'Uno' => 1, 'Dos' => 2, 'Tres' => 3 })
    end

    it 'returns forbidden if trying to access a forbidden setting' do
      get :index, params: { names: %w[SettingName RoleMapping] }

      expect(response).to have_http_status(:forbidden)
    end
  end
end
