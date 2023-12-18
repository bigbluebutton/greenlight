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
      response_recording_ids = response.parsed_body['data'].pluck('id')
      expect(response_recording_ids).to match_array(recordings.pluck(:id))
    end

    it 'returns no ids when there are no recordings that belong to current_user' do
      create_list(:room, 5, user:)
      get :index

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data']).to be_empty
    end

    it 'returns the recordings according to the query' do
      recordings = create_list(:recording, 5) do |recording|
        recording.name = "Greenlight #{rand(100 - 999)}"
      end

      create(:room, user:, recordings:)

      create_list(:recording, 10)

      get :index, params: { search: 'greenlight' }
      response_recording_ids = response.parsed_body['data'].pluck('id')
      expect(response_recording_ids).to match_array(recordings.pluck(:id))
    end

    it 'returns all the recordings since they all have presentation format' do
      recordings = create_list(:recording, 5) do |recording|
        recording.name = "Greenlight #{rand(100 - 999)}"
      end

      create(:room, user:, recordings:)

      create_list(:recording, 10)

      get :index, params: { search: 'presentation' }
      response_recording_ids = response.parsed_body['data'].pluck('id')
      expect(response_recording_ids).to match_array(recordings.pluck(:id))
    end

    it 'returns all the recordings since they all have unpublished visibility' do
      recordings = create_list(:recording, 5) do |recording|
        recording.name = "Greenlight #{rand(100 - 999)}"
      end

      create(:room, user:, recordings:)

      create_list(:recording, 10)

      get :index, params: { search: 'unpublished' }
      response_recording_ids = response.parsed_body['data'].pluck('id')
      expect(response_recording_ids).to match_array(recordings.pluck(:id))
    end

    it 'returns all recordings if the search bar is empty' do
      recordings = create_list(:recording, 5)
      create(:room, user:, recordings:)

      get :index, params: { search: '' }
      response_recording_ids = response.parsed_body['data'].pluck('id')
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
        expect(response.parsed_body['data'].pluck('name')).to eq(%w[C B A])
      end

      it 'orders the recordings list by column and direction ASC' do
        get :index, params: { sort: { column: 'name', direction: 'ASC' } }
        expect(response).to have_http_status(:ok)
        # Order is important match_array isn't adequate for this test.
        expect(response.parsed_body['data'].pluck('name')).to eq(%w[A B C])
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
    let(:recording) { create(:recording, room:) }

    it 'updates a recordings visibility' do
      expect_any_instance_of(BigBlueButtonApi)
        .to receive(:update_recording_visibility)
        .with(record_id: recording.record_id, visibility: Recording::VISIBILITIES[:published])

      expect do
        post :update_visibility, params: { visibility: Recording::VISIBILITIES[:published], id: recording.record_id }
      end.to(change { recording.reload.visibility })

      expect(response).to have_http_status(:ok)
    end

    context 'AccessToVisibilities permission' do
      before do
        RolePermission.find_by(role: user.role, permission: Permission.find_by(name: 'AccessToVisibilities')).update(value: ['Published'])
      end

      it 'returns forbidden if the user is not permitted to use that format' do
        expect_any_instance_of(BigBlueButtonApi).not_to receive(:update_recording_visibility)

        expect do
          post :update_visibility, params: { visibility: 'Unpublished', id: recording.record_id }
        end.not_to(change { recording.reload.visibility })

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'Unknown visibility' do
      it 'returns :forbidden and does not update the recording' do
        expect_any_instance_of(BigBlueButtonApi).not_to receive(:update_recording_visibility)

        expect do
          post :update_visibility, params: { visibility: '404', id: recording.record_id }
        end.not_to(change { recording.reload.visibility })

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'shared access' do
      let(:signed_in_user) { create(:user) }
      let(:recording) { create(:recording, room:, visibility: Recording::VISIBILITIES[:published]) }

      before do
        sign_in_user(signed_in_user)

        # IDK where this is created so, small hack to remove it
        RolePermission.find_by(permission: Permission.find_by(name: 'AccessToVisibilities'), value: 'false').destroy
      end

      it 'allows a shared user to update a recording visibility' do
        create(:shared_access, user_id: signed_in_user.id, room_id: room.id)

        expect_any_instance_of(BigBlueButtonApi)
          .to receive(:update_recording_visibility)
          .with(record_id: recording.record_id, visibility: Recording::VISIBILITIES[:unpublished])

        expect do
          post :update_visibility, params: { visibility: Recording::VISIBILITIES[:unpublished], id: recording.record_id }
        end.to(change { recording.reload.visibility })

        expect(response).to have_http_status(:ok)
      end

      it 'disallows a none shared user to update a recording visibility' do
        expect_any_instance_of(BigBlueButtonApi).not_to receive(:update_recording_visibility)

        expect do
          post :update_visibility, params: { visibility: Recording::VISIBILITIES[:unpublished], id: recording.record_id }
        end.not_to(change { recording.reload.visibility })

        expect(response).to have_http_status(:forbidden)
      end
    end

    # TODO: samuel - add tests for user_with_manage_recordings_permission
  end

  describe '#recordings_count' do
    it 'returns the total count of recordings of a user' do
      recordings = create_list(:recording, 5)
      create_list(:room, 5, user:, recordings:)

      get :recordings_count
      expect(response.parsed_body['data']).to be(5)
    end
  end

  describe '#recording_url' do
    let(:room) { create(:room, user:) }

    before do
      allow_any_instance_of(BigBlueButtonApi).to receive(:get_recording).and_return(
        playback: { format: [{ type: 'screenshare', url: 'https://test.com/screenshare' }, { type: 'video', url: 'https://test.com/video' }] }
      )
    end

    context 'format not passed' do
      context 'Protected recording' do
        let(:recording) do
          create(:recording, visibility: [
            Recording::VISIBILITIES[:protected],
            Recording::VISIBILITIES[:public_protected]
          ].sample,
                             room:)
        end

        it 'makes a call to BBB and returns the URLs' do
          post :recording_url, params: { id: recording.record_id }

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to match_array ['https://test.com/screenshare', 'https://test.com/video']
        end

        context 'Single playback format' do
          before do
            allow_any_instance_of(BigBlueButtonApi).to receive(:get_recording).and_return(
              playback: { format: { type: 'screenshare', url: 'https://test.com/screenshare' } }
            )
          end

          it 'makes a call to BBB and returns the URL' do
            post :recording_url, params: { id: recording.record_id }

            expect(response).to have_http_status(:ok)
            expect(response.parsed_body).to eq ['https://test.com/screenshare']
          end
        end
      end

      context 'Unprotected recording' do
        let(:recording) do
          create(:recording, visibility: [
            Recording::VISIBILITIES[:published],
            Recording::VISIBILITIES[:unpublished],
            Recording::VISIBILITIES[:public]
          ].sample,
                             room:)
        end

        before { create_list(:format, Faker::Number.within(range: 1..3), recording:) }

        it 'returns the recording record formats URLs' do
          post :recording_url, params: { id: recording.record_id }

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to match_array recording.formats.pluck(:url)
        end
      end
    end

    context 'format is passed' do
      context 'Protected recording' do
        let(:recording) do
          create(:recording, visibility: [
            Recording::VISIBILITIES[:protected],
            Recording::VISIBILITIES[:public_protected]
          ].sample,
                             room:)
        end

        before { create(:format, recording:, recording_type: 'screenshare', url: 'https://invalid.com/screenshare') }

        it 'makes a call to BBB and returns the URL' do
          post :recording_url, params: { id: recording.record_id, recording_format: 'screenshare' }

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body['data']).to eq 'https://test.com/screenshare'
        end

        context 'Single playback format' do
          before do
            allow_any_instance_of(BigBlueButtonApi).to receive(:get_recording).and_return(
              playback: { format: { type: 'screenshare', url: 'https://test.com/screenshare/solo' } }
            )
          end

          it 'makes a call to BBB and returns the URL' do
            post :recording_url, params: { id: recording.record_id, recording_format: 'screenshare' }

            expect(response).to have_http_status(:ok)
            expect(response.parsed_body['data']).to eq 'https://test.com/screenshare/solo'
          end
        end

        context 'Inexistent format' do
          it 'returns :not_found' do
            post :recording_url, params: { id: recording.record_id, recording_format: '404' }

            expect(response).to have_http_status(:not_found)
            expect(response.parsed_body['data']).to be_blank
          end
        end
      end

      context 'Unprotected recording' do
        let(:recording) do
          create(:recording, visibility: [
            Recording::VISIBILITIES[:published],
            Recording::VISIBILITIES[:unpublished],
            Recording::VISIBILITIES[:public]
          ].sample,
                             room:)
        end

        let(:target_format) { create(:format, recording:, recording_type: 'screenshare') }

        before { create_list(:format, 2, recording:) }

        it 'returns the formats URL' do
          post :recording_url, params: { id: recording.record_id, recording_format: target_format.recording_type }

          expect(response).to have_http_status(:ok)
          expect(response.parsed_body['data']).to eq target_format.url
        end

        context 'Inexistent format' do
          it 'returns :not_found' do
            post :recording_url, params: { id: recording.record_id, recording_format: '404' }

            expect(response).to have_http_status(:not_found)
            expect(response.parsed_body['data']).to be_blank
          end
        end
      end
    end

    context 'Other users' do
      let(:recording) { create(:recording, room:) }
      let(:signed_in_user) { create(:user) }

      before { sign_in_user(signed_in_user) }

      it 'returns :forbidden' do
        post :recording_url, params: { id: recording.record_id }

        expect(response).to have_http_status(:forbidden)
      end

      context 'shared room' do
        before do
          create(:shared_access, user_id: signed_in_user.id, room_id: room.id)
        end

        it 'returns :ok' do
          post :recording_url, params: { id: recording.record_id }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'Recordings Manager' do
        before { sign_in_user(user_with_manage_recordings_permission) }

        it 'returns :ok' do
          post :recording_url, params: { id: recording.record_id }

          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'Unauthenticated' do
      before { sign_out_user }

      describe 'Public recordings' do
        let(:recording) { create(:recording, visibility: [Recording::VISIBILITIES[:public], Recording::VISIBILITIES[:public_protected]].sample) }

        it 'returns :ok' do
          post :recording_url, params: { id: recording.record_id }

          expect(response).to have_http_status(:ok)
        end
      end

      describe 'Private recordings' do
        let(:recording) do
          create(:recording,
                 visibility: [Recording::VISIBILITIES[:protected], Recording::VISIBILITIES[:published], Recording::VISIBILITIES[:unpublished]].sample)
        end

        it 'returns :forbidden' do
          post :recording_url, params: { id: recording.record_id }

          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'Inexistent recording' do
      it 'returns :not_found' do
        post :recording_url, params: { id: '404' }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

def http_ok_response
  Net::HTTPSuccess.new(1.0, '200', 'OK')
end
