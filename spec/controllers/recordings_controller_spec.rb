# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::RecordingsController, type: :controller do
  before do
    request.headers['ACCEPT'] = 'application/json'
    sign_in_user(user)
  end

  let(:user) { create(:user) }
  let(:user_with_manage_recordings_permission) { create(:user, :with_manage_recordings_permission) }

  describe '#index' do
    it 'returns recordings ids that belong to current_user' do
      recordings = create_list(:recording, 5)
      create_list(:room, 5, user:, recordings:)
      get :index

      expect(response).to have_http_status(:ok)
      response_recording_ids = JSON.parse(response.body)['data'].map { |recording| recording['id'] }
      expect(response_recording_ids).to match_array(recordings.pluck(:id))
    end

    it 'returns no ids when there are no recordings that belong to current_user' do
      create_list(:room, 5, user:)
      get :index

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']).to be_empty
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

    it 'returns all the recordings since they all have presentation format' do
      recordings = create_list(:recording, 5) do |recording|
        recording.name = "Greenlight #{rand(100 - 999)}"
      end

      create(:room, user:, recordings:)

      create_list(:recording, 10)

      get :index, params: { search: 'presentation' }
      response_recording_ids = JSON.parse(response.body)['data'].map { |recording| recording['id'] }
      expect(response_recording_ids).to match_array(recordings.pluck(:id))
    end

    it 'returns all the recordings since they all have unpublished visibility' do
      recordings = create_list(:recording, 5) do |recording|
        recording.name = "Greenlight #{rand(100 - 999)}"
      end

      create(:room, user:, recordings:)

      create_list(:recording, 10)

      get :index, params: { search: 'unpublished' }
      response_recording_ids = JSON.parse(response.body)['data'].map { |recording| recording['id'] }
      expect(response_recording_ids).to match_array(recordings.pluck(:id))
    end

    it 'returns all recordings if the search bar is empty' do
      recordings = create_list(:recording, 5)
      create(:room, user:, recordings:)

      get :index, params: { search: '' }
      response_recording_ids = JSON.parse(response.body)['data'].map { |recording| recording['id'] }
      expect(response_recording_ids).to match_array(recordings.pluck(:id))
    end

    context 'ordering' do
      before do
        recordings = [create(:recording, name: 'B'), create(:recording, name: 'A'), create(:recording, name: 'C')]

        create(:room, user:, recordings:)
      end

      it 'orders the recordings list by column and direction DESC' do
        get :index, params: { sort: { column: 'name', direction: 'DESC' } }
        expect(response).to have_http_status(:ok)
        # Order is important match_array isn't adequate for this test.
        expect(JSON.parse(response.body)['data'].pluck('name')).to eq(%w[C B A])
      end

      it 'orders the recordings list by column and direction ASC' do
        get :index, params: { sort: { column: 'name', direction: 'ASC' } }
        expect(response).to have_http_status(:ok)
        # Order is important match_array isn't adequate for this test.
        expect(JSON.parse(response.body)['data'].pluck('name')).to eq(%w[A B C])
      end
    end
  end

  describe '#update' do
    let(:room) { create(:room, user:) }
    let(:recording) { create(:recording, room:) }

    before do
      allow_any_instance_of(BigBlueButtonApi).to receive(:update_recordings).and_return(http_ok_response)
    end

    it 'updates the recordings name with valid params returning :ok status code' do
      expect_any_instance_of(BigBlueButtonApi).to receive(:update_recordings).with(record_id: recording.record_id,
                                                                                   meta_hash: { meta_name: 'My Awesome Recording!' })

      expect { post :update, params: { recording: { name: 'My Awesome Recording!' }, id: recording.record_id } }.to(change { recording.reload.name })
      expect(response).to have_http_status(:ok)
    end

    it 'does not update the recordings name for invalid params returning a :bad_request status code' do
      expect_any_instance_of(BigBlueButtonApi).not_to receive(:update_recordings)

      expect do
        post :update,
             params: { recording: { name: '' }, id: recording.record_id }
      end.not_to(change { recording.reload.name })

      expect(response).to have_http_status(:bad_request)
    end

    it 'does not update the recordings name for invalid recording id returning :not_found status code' do
      expect_any_instance_of(BigBlueButtonApi).not_to receive(:update_recordings)
      post :update, params: { recording: { name: '' }, id: '404' }
      expect(response).to have_http_status(:not_found)
    end

    it 'allows a shared user to update a recording name' do
      shared_user = create(:user)
      create(:shared_access, user_id: shared_user.id, room_id: room.id)
      sign_in_user(shared_user)

      expect_any_instance_of(BigBlueButtonApi).to receive(:update_recordings).with(record_id: recording.record_id,
                                                                                   meta_hash: { meta_name: 'My Awesome Recording!' })

      expect { post :update, params: { recording: { name: 'My Awesome Recording!' }, id: recording.record_id } }.to(change { recording.reload.name })
      expect(response).to have_http_status(:ok)
    end

    it 'user cannot update another users recordings name' do
      user = create(:user)
      room = create(:room, user:)
      recording = create(:recording, room:)
      expect { post :update, params: { recording: { name: 'My Awesome Recording!' }, id: recording.record_id } }.not_to(change do
                                                                                                                          recording.reload.name
                                                                                                                        end)
      expect(response).to have_http_status(:forbidden)
    end

    context 'user has ManageRecordings permission' do
      before do
        sign_in_user(user_with_manage_recordings_permission)
      end

      it 'updates another users recordings name' do
        user = create(:user)
        room = create(:room, user:)
        recording = create(:recording, room:)
        expect { post :update, params: { recording: { name: 'My Awesome Recording!' }, id: recording.record_id } }.to(change do
          recording.reload.name
        end)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe '#update_visibility' do
    let(:room) { create(:room, user:) }
    let(:published_recording) { create(:recording, room:, visibility: 'Published') }
    let(:unpublished_recording) { create(:recording, room:, visibility: 'Unpublished') }
    let(:protected_recording) { create(:recording, room:, visibility: 'Protected') }

    it 'changes the recording from Published to Unpublished on the bbb server' do
      expect_any_instance_of(BigBlueButtonApi).to receive(:publish_recordings).with(record_ids: published_recording.record_id, publish: false)
      expect_any_instance_of(BigBlueButtonApi).not_to receive(:update_recordings)
      post :update_visibility, params: { visibility: 'Unpublished', id: published_recording.record_id }
    end

    it 'changes the recording from Published to Protected on the bbb server' do
      expect_any_instance_of(BigBlueButtonApi).to receive(:update_recordings).with(record_id: published_recording.record_id,
                                                                                   meta_hash: { protect: true })
      expect_any_instance_of(BigBlueButtonApi).not_to receive(:publish_recordings)
      post :update_visibility, params: { visibility: 'Protected', id: published_recording.record_id }
    end

    it 'changes the recording from Unpublished to Protected on the bbb server' do
      expect_any_instance_of(BigBlueButtonApi).to receive(:publish_recordings).with(record_ids: unpublished_recording.record_id, publish: true)
      expect_any_instance_of(BigBlueButtonApi).to receive(:update_recordings).with(record_id: unpublished_recording.record_id,
                                                                                   meta_hash: { protect: true })
      post :update_visibility, params: { visibility: 'Protected', id: unpublished_recording.record_id }
    end

    it 'changes the recording from Unpublished to Published on the bbb server' do
      expect_any_instance_of(BigBlueButtonApi).to receive(:publish_recordings).with(record_ids: unpublished_recording.record_id, publish: true)
      expect_any_instance_of(BigBlueButtonApi).not_to receive(:update_recordings)
      post :update_visibility, params: { visibility: 'Published', id: unpublished_recording.record_id }
    end

    it 'changes the recording from Protected to Published on the bbb server' do
      expect_any_instance_of(BigBlueButtonApi).not_to receive(:publish_recordings)
      expect_any_instance_of(BigBlueButtonApi).to receive(:update_recordings).with(record_id: protected_recording.record_id,
                                                                                   meta_hash: { protect: false })
      post :update_visibility, params: { visibility: 'Published', id: protected_recording.record_id }
    end

    it 'changes the recording from Protected to Unpublished on the bbb server' do
      expect_any_instance_of(BigBlueButtonApi).to receive(:publish_recordings).with(record_ids: protected_recording.record_id, publish: false)
      expect_any_instance_of(BigBlueButtonApi).to receive(:update_recordings).with(record_id: protected_recording.record_id,
                                                                                   meta_hash: { protect: false })
      post :update_visibility, params: { visibility: 'Unpublished', id: protected_recording.record_id }
    end

    it 'changes the local recording visibility' do
      allow_any_instance_of(BigBlueButtonApi).to receive(:publish_recordings)
      post :update_visibility, params: { visibility: 'Unpublished', id: unpublished_recording.record_id }
      expect(unpublished_recording.reload.visibility).to eq('Unpublished')
    end

    it 'allows a shared user to update a recording visibility' do
      shared_user = create(:user)
      create(:shared_access, user_id: shared_user.id, room_id: room.id)
      sign_in_user(shared_user)

      expect_any_instance_of(BigBlueButtonApi).to receive(:publish_recordings).with(record_ids: published_recording.record_id, publish: false)
      expect_any_instance_of(BigBlueButtonApi).not_to receive(:update_recordings)
      expect do
        post :update_visibility, params: { visibility: 'Unpublished', id: published_recording.record_id }
      end.to(change { published_recording.reload.visibility })
    end

    # TODO: samuel - add tests for user_with_manage_recordings_permission
  end

  describe '#recordings_count' do
    it 'returns the total count of recordings of a user' do
      recordings = create_list(:recording, 5)
      create_list(:room, 5, user:, recordings:)

      get :recordings_count
      expect(JSON.parse(response.body)['data']).to be(5)
    end
  end
end

def http_ok_response
  Net::HTTPSuccess.new(1.0, '200', 'OK')
end
