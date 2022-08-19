# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::ServerRoomsController, type: :controller do
  let(:user) { create(:user) }
  let(:user_with_manage_rooms_permission) { create(:user, :with_manage_rooms_permission)}

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user_with_manage_rooms_permission.id
  end

  describe '#index' do
    it 'returns all the Server Rooms from all users' do
      user_one = create(:user)
      user_two = create(:user)

      create_list(:room, 2, user_id: user_one.id)
      create_list(:room, 2, user_id: user_two.id)

      allow_any_instance_of(BigBlueButtonApi).to receive(:active_meetings).and_return([])
      get :index
      expect(JSON.parse(response.body)['data'].map { |room| room['friendly_id'] })
        .to match_array(Room.all.pluck(:friendly_id))
    end

    it 'returns the server room status as active if the meeting has started' do
      active_server_room = create(:room)
      active_server_room.update(meeting_id: 'hulsdzwvitlk1dbekzxdprshsxmvycvar0jeaszc')

      allow_any_instance_of(BigBlueButtonApi).to receive(:active_meetings).and_return(bbb_meetings)
      get :index
      expect(JSON.parse(response.body)['data'][0]['active']).to be(true)
    end

    it 'returns the number of participants in an active server room' do
      active_server_room = create(:room)
      active_server_room.update(meeting_id: 'hulsdzwvitlk1dbekzxdprshsxmvycvar0jeaszc')

      allow_any_instance_of(BigBlueButtonApi).to receive(:active_meetings).and_return(bbb_meetings)
      get :index
      expect(JSON.parse(response.body)['data'][0]['participants']).to be(1)
    end

    it 'returns the server status as not running if BBB server does not return any active meetings' do
      create(:room)

      allow_any_instance_of(BigBlueButtonApi).to receive(:active_meetings).and_return([])
      get :index
      expect(JSON.parse(response.body)['data'][0]['active']).to be(false)
    end

    context 'user without ManageRooms permission' do
      before do
        session[:user_id] = user.id
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
