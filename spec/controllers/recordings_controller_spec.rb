# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::RecordingsController, type: :controller do
  let(:user) { create(:user) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user.id
  end

  describe '#index' do
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

    it 'returns the recordings according to the query' do
      recordings = create_list(:recording, 5) do |recording|
        recording.name = "Greenlight #{rand(100 - 999)}"
      end

      create(:room, user:, recordings:)

      create_list(:recording, 10)

      get :index, params: { search: 'greenlight' }
      response_recording_ids = JSON.parse(response.body)['data'].map { |recording| recording['id'] }
      expect(response_recording_ids).to match_array(recordings.pluck(:id))
    end

    it 'returns all recordings if the search bar is empty' do
      recordings = create_list(:recording, 10)
      create(:room, user:, recordings:)

      get :index, params: { search: '' }
      response_recording_ids = JSON.parse(response.body)['data'].map { |recording| recording['id'] }
      expect(response_recording_ids).to match_array(recordings.pluck(:id))
    end
  end

  # TODO: - Uncomment once delete_recordings is no longer in destroy
  # describe '#destroy' do
  #   it 'deletes recording from the database' do
  #     recording = create(:recording)
  #     expect { delete :destroy, params: { id: recording.id } }.to change(Recording, :count).by(-1)
  #   end

  #   it 'deletes formats associated with the recording from the database' do
  #     recording = create(:recording)
  #     create_list(:format, 5, recording:)
  #     expect { delete :destroy, params: { id: recording.id } }.to change(Format, :count).by(-5)
  #   end
  # end

  describe '#recordings' do
    it 'calls the RecordingsSync service correctly' do
      expect_any_instance_of(RecordingsSync).to receive(:call)
      get :resync
    end

    it 'calls the RecordingsSync service with correct params' do
      expect(RecordingsSync).to receive(:new).with(user:)
      get :resync
    end
  end
end
