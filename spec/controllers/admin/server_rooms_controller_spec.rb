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

RSpec.describe Api::V1::Admin::ServerRoomsController, type: :controller do
  let(:user) { create(:user) }
  let(:user_with_manage_rooms_permission) { create(:user, :with_manage_rooms_permission) }

  before do
    Faker::Construction.unique.clear
    request.headers['ACCEPT'] = 'application/json'
    sign_in_user(user_with_manage_rooms_permission)
  end

  describe '#index' do
    it 'returns all the Server Rooms from all users' do
      user_one = create(:user)
      user_two = create(:user)

      create_list(:room, 2, user_id: user_one.id)
      create_list(:room, 2, user_id: user_two.id)

      get :index
      expect(response.parsed_body['data'].pluck('friendly_id'))
        .to match_array(Room.all.pluck(:friendly_id))
    end

    context 'SuperAdmin accessing rooms for provider other than current provider' do
      before do
        super_admin_role = create(:role, provider: 'bn', name: 'SuperAdmin')
        super_admin = create(:user, provider: 'bn', role: super_admin_role)
        sign_in_user(super_admin)
      end

      it 'returns all the Server Rooms from all users' do
        user_one = create(:user)
        user_two = create(:user)

        create_list(:room, 2, user_id: user_one.id)
        create_list(:room, 2, user_id: user_two.id)

        get :index
        expect(response.parsed_body['data'].pluck('friendly_id'))
          .to match_array(Room.all.pluck(:friendly_id))
      end
    end

    it 'excludes rooms whose owners have a different provider' do
      user1 = create(:user, provider: 'greenlight')
      role_with_provider_test = create(:role, provider: 'test')
      user2 = create(:user, provider: 'test', role: role_with_provider_test)
      rooms = create_list(:room, 2, user: user1)
      create_list(:room, 2, user: user2)

      get :index
      expect(response.parsed_body['data'].pluck('id')).to match_array(rooms.pluck(:id))
    end

    context 'user without ManageRooms permission' do
      before do
        sign_in_user(user)
      end

      it 'cannot return the Server Rooms' do
        user_one = create(:user)
        user_two = create(:user)
        create_list(:room, 2, user_id: user_one.id)
        create_list(:room, 2, user_id: user_two.id)

        allow_any_instance_of(BigBlueButtonApi).to receive(:active_meetings).and_return([])
        get :index
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe '#resync' do
    let(:fake_recording_sync) { instance_double(RecordingsSync) }
    let(:room) { create(:room) }

    before do
      allow(RecordingsSync).to receive(:new).and_return(fake_recording_sync)
      allow(fake_recording_sync).to receive(:call).and_return({ 'recordings' => 'values' })
    end

    # TODO: - samuel current_user is user_with_manage.. I think we should keep a regular user as default even in admin specs
    it 'calls the RecordingsSync service with correct params' do
      expect(RecordingsSync).to receive(:new).with(room:, provider: 'greenlight')
      expect(fake_recording_sync).to receive(:call)
      get :resync, params: { friendly_id: room.friendly_id }
      expect(response).to have_http_status(:ok)
    end

    context 'user without ManageRooms permission' do
      before do
        sign_in_user(user)
      end

      it 'call the RecordingsSync service' do
        expect(RecordingsSync).not_to receive(:new).with(room:, provider: 'greenlight')
        get :resync, params: { friendly_id: room.friendly_id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  private

  def bbb_meetings
    [{
      meetingName: 'Meeting 1',
      meetingID: 'hulsdzwvitlk1dbekzxdprshsxmvycvar0jeaszc',
      internalMeetingID: 'f92e335f4aa90883d0454990d1e292c9cf2a9411-1657223036433',
      createTime: 1_657_223_036_433,
      createDate: 'Thu Jul 07 19:43:56 UTC 2022',
      voiceBridge: 71_094,
      dialNumber: '613-555-1234',
      attendeePW: 'PfkAgstb',
      moderatorPW: 'FySoLjmx',
      running: true,
      duration: '0',
      hasUserJoined: 'true',
      recording: 'false',
      hasBeenForciblyEnded: false,
      startTime: '1657223036446',
      endTime: '0',
      participantCount: 1,
      listenerCount: 0,
      voiceParticipantCount: '0',
      videoCount: 0,
      maxUsers: '0',
      moderatorCount: '1',
      attendees: { attendee: { userID: 'w_jololdrmvk0l',
                               fullName: 'Smith',
                               role: 'MODERATOR',
                               isPresenter: 'true',
                               isListeningOnly: 'false',
                               hasJoinedVoice: 'false',
                               hasVideo: 'false',
                               clientType: 'HTML5' } },
      metadata: { 'bbb-origin-version': '3',
                  'bbb-recording-ready-url': 'http://localhost:3000/recording_ready',
                  'bbb-origin': 'greenlight',
                  endcallbackurl: 'http://localhost:3000/meeting_ended' },
      isBreakout: 'false'
    }]
  end
end
