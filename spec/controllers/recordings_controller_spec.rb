# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::RecordingsController, type: :controller do
  let(:user) { create(:user) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user.id
  end

  # TODO: Hadi - Make test work with current_user
  describe 'index' do
    it 'returns recordings ids that belong to current_user' do
      recordings = create_list(:recording, 6)
      create_list(:room, 5, user:, recordings:)
      get :index
      expect(response).to have_http_status(:ok)
      response_recording_ids = JSON.parse(response.body)['data'].map { |recording| recording['id'] }
      expect(response_recording_ids).to eq(recordings.pluck(:id))
    end

    it 'returns no ids when there are no recordings that belong to current_user' do
      create_list(:room, 5, user:)
      get :index
      expect(response).to have_http_status(:ok)
      response_recording_ids = JSON.parse(response.body)['data'].map { |recording| recording['id'] }
      expect(response_recording_ids).to be_empty
    end
  end
end
