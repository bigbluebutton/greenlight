# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::RecordingsController, type: :controller do
  let(:manage_recordings_role) { create(:role) }
  let(:user) { create(:user, role: manage_recordings_role) }
  let(:manage_recordings_permission) { create(:permission, name: 'ManageRecordings') }
  let!(:manage_recordings_role_permission) do
    create(:role_permission,
           role: manage_recordings_role,
           permission: manage_recordings_permission,
           value: 'true',
           provider: 'greenlight')
  end

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user.id
  end

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

    context 'user without ManageRecordings permission' do
      before do
        manage_recordings_role_permission.update!(value: 'false')
      end

      it 'user without ManageRecordings permission cannot update the recordings name' do
        expect { post :update, params: { recording: { name: 'My Awesome Recording!' }, id: recording.record_id } }.not_to(change do
                                                                                                                            recording.reload.name
                                                                                                                          end)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  # TODO: - Uncomment once delete_recordings is no longer in destroy
  # describe '#destroy' do
  #   it 'deletes recording from the database' do
  #     recording = create(:recording)
  #     expect { delete :destroy, params: { id: recording.id } }.to change(Recording, :count).by(-1)
  #   end
  #   it 'admin without ManageRecordings permission cannot delete recording from the database' do
  #     recording = create(:recording)
  #     expect { delete :destroy, params: { id: recording.id } }.not_to change(Recording, :count)
  #     expect(response).to have_http_status(:forbidden)
  #   end
  #   it 'deletes formats associated with the recording from the database' do
  #     recording = create(:recording)
  #     create_list(:format, 5, recording:)
  #     expect { delete :destroy, params: { id: recording.id } }.to change(Format, :count).by(-5)
  #   end
  # end

  describe '#update_visibility' do
    it 'changes the recording from Published to Unpublished on the bbb server' do
      recording = create(:recording, visibility: 'Published')
      expect_any_instance_of(BigBlueButtonApi).to receive(:publish_recordings).with(record_ids: recording.record_id, publish: false)
      expect_any_instance_of(BigBlueButtonApi).not_to receive(:update_recordings)
      post :update_visibility, params: { visibility: 'Unpublished', id: recording.record_id }
    end

    it 'changes the recording from Published to Protected on the bbb server' do
      recording = create(:recording, visibility: 'Published')
      expect_any_instance_of(BigBlueButtonApi).to receive(:update_recordings).with(record_id: recording.record_id,
                                                                                   meta_hash: { protect: true })
      expect_any_instance_of(BigBlueButtonApi).not_to receive(:publish_recordings)
      post :update_visibility, params: { visibility: 'Protected', id: recording.record_id }
    end

    it 'changes the recording from Unpublished to Protected on the bbb server' do
      recording = create(:recording, visibility: 'Unpublished')
      expect_any_instance_of(BigBlueButtonApi).to receive(:publish_recordings).with(record_ids: recording.record_id, publish: true)
      expect_any_instance_of(BigBlueButtonApi).to receive(:update_recordings).with(record_id: recording.record_id,
                                                                                   meta_hash: { protect: true })
      post :update_visibility, params: { visibility: 'Protected', id: recording.record_id }
    end

    it 'changes the recording from Unpublished to Published on the bbb server' do
      recording = create(:recording, visibility: 'Unpublished')
      expect_any_instance_of(BigBlueButtonApi).to receive(:publish_recordings).with(record_ids: recording.record_id, publish: true)
      expect_any_instance_of(BigBlueButtonApi).not_to receive(:update_recordings)
      post :update_visibility, params: { visibility: 'Published', id: recording.record_id }
    end

    it 'changes the recording from Protected to Published on the bbb server' do
      recording = create(:recording, visibility: 'Protected')
      expect_any_instance_of(BigBlueButtonApi).not_to receive(:publish_recordings)
      expect_any_instance_of(BigBlueButtonApi).to receive(:update_recordings).with(record_id: recording.record_id,
                                                                                   meta_hash: { protect: false })
      post :update_visibility, params: { visibility: 'Published', id: recording.record_id }
    end

    it 'changes the recording from Protected to Unpublished on the bbb server' do
      recording = create(:recording, visibility: 'Protected')
      expect_any_instance_of(BigBlueButtonApi).to receive(:publish_recordings).with(record_ids: recording.record_id, publish: false)
      expect_any_instance_of(BigBlueButtonApi).to receive(:update_recordings).with(record_id: recording.record_id,
                                                                                   meta_hash: { protect: false })
      post :update_visibility, params: { visibility: 'Unpublished', id: recording.record_id }
    end

    it 'changes the local recording visibility' do
      recording = create(:recording, visibility: 'Published')
      allow_any_instance_of(BigBlueButtonApi).to receive(:publish_recordings)
      post :update_visibility, params: { visibility: 'Unpublished', id: recording.record_id }
      expect(recording.reload.visibility).to eq('Unpublished')
    end
  end
end

def http_ok_response
  Net::HTTPSuccess.new(1.0, '200', 'OK')
end
