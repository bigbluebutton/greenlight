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

RSpec.describe Api::V1::RoomsConfigurationsController, type: :controller do
  let(:user) { create(:user) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    sign_in_user(user)
  end

  describe 'rooms_configurations#index' do
    it 'returns a hash of rooms configurations :name => :value' do
      meeting_options = [
        create(:meeting_option, name: 'TRUE'), create(:meeting_option, name: 'FALSE'), create(:meeting_option, name: 'OPTIONAL')
      ]

      create(:rooms_configuration, meeting_option: meeting_options[0], value: 'true')
      create(:rooms_configuration, meeting_option: meeting_options[1], value: 'false')
      create(:rooms_configuration, meeting_option: meeting_options[2], value: 'optional')

      get :index

      expect(JSON.parse(response.body)['data']).to eq({
                                                        'TRUE' => 'true',
                                                        'FALSE' => 'false',
                                                        'OPTIONAL' => 'optional'
                                                      })
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'rooms_configurations#show' do
    before do
      create(:rooms_configuration, meeting_option: create(:meeting_option, name: 'record'), value: 'false')
    end

    it 'returns the correct configuration value' do
      get :show, params: { name: 'record' }

      expect(JSON.parse(response.body)['data']).to eq('false')

      expect(response).to have_http_status(:ok)
    end

    it 'returns :not_found if the configuration :name passed does not exist' do
      get :show, params: { name: 'nonexistent' }

      expect(response).to have_http_status(:not_found)
    end
  end
end
