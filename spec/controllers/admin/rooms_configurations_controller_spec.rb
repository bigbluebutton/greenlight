# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::RoomsConfigurationsController, type: :controller do
  before { request.headers['ACCEPT'] = 'application/json' }

  describe 'rooms_configurations#update' do
    it 'updates the rooms configuration :value' do
      meeting_option = create(:meeting_option, name: 'Option')
      rooms_config = create(:rooms_configuration, meeting_option:, value: 'optional', provider: 'greenlight')

      put :update, params: { name: 'Option', RoomsConfig: { value: 'true' } }

      expect(response).to have_http_status(:ok)
      expect(rooms_config.reload.value).to eq('true')
    end

    it 'returns :not_found for unfound record by :name' do
      put :update, params: { name: 'Unkown', RoomsConfig: { value: 'true' } }

      expect(response).to have_http_status(:not_found)
    end

    it 'returns :bad_request for invalid params' do
      meeting_option = create(:meeting_option, name: 'Option')
      create(:rooms_configuration, meeting_option:, value: 'optional', provider: 'greenlight')

      put :update, params: { name: 'Option', NotRoomsConfig: { not_value: 'true' } }

      expect(response).to have_http_status(:bad_request)
    end

    it 'returns :bad_request for failed updates' do
      meeting_option = create(:meeting_option, name: 'Option')
      create(:rooms_configuration, meeting_option:, value: 'optional', provider: 'greenlight')

      put :update, params: { name: 'Option', RoomsConfig: { value: 'invalid' } }

      expect(response).to have_http_status(:bad_request)
    end
  end
end
