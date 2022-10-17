# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::ServerRecordingsController, type: :controller do
  let(:user) { create(:user) }

  let(:user_with_manage_recordings_permission) { create(:user, :with_manage_recordings_permission) }

  before do
    Faker::Construction.unique.clear
    request.headers['ACCEPT'] = 'application/json'
    sign_in_user(user_with_manage_recordings_permission)
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

    it 'excludes rooms whose owners have a different provider' do
      room1 = create(:room, user: create(:user, provider: 'greenlight'))
      role_with_provider_test = create(:role, provider: 'test')
      room2 = create(:room, user: create(:user, provider: 'test', role: role_with_provider_test))

      recs = create_list(:recording, 2, room: room1)
      create_list(:recording, 2, room: room2)

      get :index

      expect(JSON.parse(response.body)['data'].pluck('id')).to match_array(recs.pluck(:id))
    end

    context 'user without ManageRecordings permission' do
      before do
        sign_in_user(user)
      end

      it 'cannot return the list of recordings' do
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
end
