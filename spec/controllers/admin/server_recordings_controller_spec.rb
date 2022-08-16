# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::ServerRecordingsController, type: :controller do
  let(:manage_recordings_role) { create(:role) }
  let(:user) { create(:user, role: manage_recordings_role) }
  let(:manage_recordings_permission) { create(:permission, name: 'ManageRecordings') }
  let!(:manage_recordings_role_permission) do
    create(:role_permission,
           role: manage_recordings_role,
           permission: manage_recordings_permission,
           value: 'true')
  end

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user.id
  end

  describe '#index' do
    it 'returns the list of recordings' do
      recordings = [create(:recording, name: 'Tinky-Winky'), create(:recording, name: 'Dipsy'), create(:recording, name: 'Laa-Laa')]

      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data'].pluck('id')).to match_array(recordings.pluck(:id))
    end

    it 'returns the recordings according to the query' do
      search_recordings = [create(:recording, name: 'Recording 1'), create(:recording, name: 'Recording 2'), create(:recording, name: 'Recording 3')]

      get :index, params: { search: 'recording' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data'].pluck('id')).to match_array(search_recordings.pluck(:id))
    end

    it 'returns all recordings if the search query is empty' do
      recordings = create_list(:recording, 5)

      get :index, params: { search: '' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data'].pluck('id')).to match_array(recordings.pluck(:id))
    end

    context 'user without ManageRecordings permission' do
      before do
        manage_recordings_role_permission.update!(value: 'false')
      end

      it 'user without ManageRecordings permission cannot return the list of recordings' do
        get :index
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'ordering' do
      before do
        create(:recording, name: 'O')
        create(:recording, name: 'O')
        create(:recording, name: 'P')
      end

      it 'orders the recordings list by column and direction DESC' do
        get :index, params: { sort: { column: 'name', direction: 'DESC' } }
        expect(response).to have_http_status(:ok)
        # Order is important match_array isn't adequate for this test.
        expect(JSON.parse(response.body)['data'].pluck('name')).to eq(%w[P O O])
      end

      it 'orders the recordings list by column and direction ASC' do
        get :index, params: { sort: { column: 'name', direction: 'ASC' } }
        expect(response).to have_http_status(:ok)
        # Order is important match_array isn't adequate for this test.
        expect(JSON.parse(response.body)['data'].pluck('name')).to eq(%w[O O P])
      end
    end
  end
  # TODO: - resync tests need to be adjusted

  describe '#resync' do
    it 'calls the RecordingsSync service correctly' do
      expect_any_instance_of(RecordingsSync).to receive(:call)
      get :resync
    end

    it 'calls the RecordingsSync service with correct params' do
      expect(RecordingsSync).to receive(:new).with(user:)
      get :resync
    end

    it 'admin without ManageRecordings permission cannot call the RecordingsSync service' do
      manage_recordings_role_permission.update!(value: 'false')
      get :resync
      expect(response).to have_http_status(:forbidden)
    end
  end
end
