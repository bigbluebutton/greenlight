# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::RoomsConfigurationsController, type: :controller do
  let(:user) { create(:user) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user.id
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
end
