# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MeetingsController, type: :controller do
  let(:role) { create(:role) }
  let(:user) { create(:user, role:) }
  let(:manage_rooms_permission) { create(:permission, name: 'ManageRooms') }
  let!(:manage_rooms_role_permission) do
    create(:role_permission,
           role_id: user.role_id,
           permission_id: manage_rooms_permission.id,
           value: 'true',
           provider: 'greenlight')
  end

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user.id
  end

  describe '#start' do
    let(:room) { create(:room, user:) }

    before do
      allow_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .and_return(meeting_starter_response)
    end

    it 'makes a call to the MeetingStarter service with the right values' do
      logout = 'http://example.com'
      request.env['HTTP_REFERER'] = logout
      presentation_url = nil

      expect(
        MeetingStarter
      ).to receive(:new).with(
        room:,
        logout_url: logout,
        presentation_url:,
        meeting_ended: meeting_ended_url,
        recording_ready: recording_ready_url
      )

      post :start, params: { friendly_id: room.friendly_id }
    end

    it 'admin cannot make call to MeetingStarter service for another room without ManageRooms permission' do
      room = create(:room)
      manage_rooms_role_permission.update!(value: 'false')

      post :start, params: { friendly_id: room.friendly_id }
      expect(response).to have_http_status(:forbidden)
    end

    it 'makes a call to the MeetingStarter service with the right values and presentation attached to room' do
      room = create(:room, user:, presentation: fixture_file_upload(file_fixture('default-avatar.png'), 'image/png'))
      logout = 'http://example.com'
      request.env['HTTP_REFERER'] = logout
      presentation_url = Rails.application.routes.url_helpers.rails_blob_url(room.presentation, host: 'test.host')

      expect(
        MeetingStarter
      ).to receive(:new).with(
        room:,
        logout_url: logout,
        presentation_url:,
        meeting_ended: meeting_ended_url,
        recording_ready: recording_ready_url
      )

      post :start, params: { friendly_id: room.friendly_id }
    end

    it 'makes a call to the BigBlueButtonApi to get the join url' do
      expect_any_instance_of(BigBlueButtonApi)
        .to receive(:join_meeting)
        .with(room:, name: user.name, role: 'Moderator')

      post :start, params: { friendly_id: room.friendly_id }
    end

    it 'returns the join url to the front-end for redirecting' do
      allow_any_instance_of(BigBlueButtonApi)
        .to receive(:join_meeting)
        .and_return('https://example.com')

      post :start, params: { friendly_id: room.friendly_id }

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['data']).to eq('https://example.com')
    end

    it 'returns an error if the user is not logged in' do
      session[:user_id] = nil

      post :start, params: { friendly_id: room.friendly_id }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe '#join' do
    before do
      allow_any_instance_of(Room).to receive(:viewer_access_code).and_return('')
      allow_any_instance_of(Room).to receive(:moderator_access_code).and_return('')
    end

    it 'joins as viewer if no access code is required nor provided' do
      room = create(:room, user:)

      expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Viewer')
      get :join, params: { friendly_id: room.friendly_id, name: user.name }
      expect(response).to have_http_status(:ok)
    end

    context 'Access codes required' do
      before do
        allow_any_instance_of(Room).to receive(:viewer_access_code).and_return('AAA')
        allow_any_instance_of(Room).to receive(:moderator_access_code).and_return('BBB')
      end

      it 'joins as viewer if the input access code correspond to the viewer access code' do
        room = create(:room, user:)

        expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Viewer')
        get :join, params: { friendly_id: room.friendly_id, name: user.name, access_code: 'AAA' }
        expect(response).to have_http_status(:ok)
      end

      it 'joins as viewer if the moderator access code is optional and the input access code is blank' do
        allow_any_instance_of(Room).to receive(:viewer_access_code).and_return('')
        room = create(:room, user:)

        expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Viewer')
        get :join, params: { friendly_id: room.friendly_id, name: user.name, access_code: '' }
        expect(response).to have_http_status(:ok)
      end

      it 'joins as moderator if access code correspond to moderator access code' do
        room = create(:room, user:)

        expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Moderator')
        get :join, params: { friendly_id: room.friendly_id, name: user.name, access_code: 'BBB' }
        expect(response).to have_http_status(:ok)
      end

      it 'joins as moderator if "glAnyoneJoinAsModerator" setting enabled and access code provided' do
        allow_any_instance_of(Room).to receive(:anyone_joins_as_moderator?).and_return(true)
        room = create(:room, user:)

        expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: 'Someone', role: 'Moderator')
        get :join, params: { friendly_id: room.friendly_id, name: 'Someone', access_code: 'AAA' }
        expect(response).to have_http_status(:ok)
      end

      it 'joins as moderator if "glAnyoneJoinAsModerator" setting enabled and access code NOT provided' do
        allow_any_instance_of(Room).to receive(:anyone_joins_as_moderator?).and_return(true)
        room = create(:room, user:)

        expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: 'Someone', role: 'Moderator')
        get :join, params: { friendly_id: room.friendly_id, name: 'Someone' }
        expect(response).to have_http_status(:ok)
      end

      it 'returns unauthorized if the access code is wrong' do
        room = create(:room, user:)

        get :join, params: { friendly_id: room.friendly_id, name: user.name, access_code: 'ZZZ' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    it 'allows access to an unauthenticated user' do
      session[:user_id] = nil

      room = create(:room, user:)

      expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Viewer')
      get :join, params: { friendly_id: room.friendly_id, name: user.name }

      expect(response).to have_http_status(:ok)
    end
  end

  describe '#status' do
    before do
      allow_any_instance_of(Room).to receive(:viewer_access_code).and_return('')
      allow_any_instance_of(Room).to receive(:moderator_access_code).and_return('')
    end

    it 'gets the joinUrl if the meeting is running' do
      room = create(:room, user:)

      allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)
      expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Viewer')

      get :status, params: { friendly_id: room.friendly_id, name: user.name }
    end

    it 'joins as viewer if no access code is required nor provided' do
      room = create(:room, user:)

      allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)
      expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Viewer')
      get :status, params: { friendly_id: room.friendly_id, name: user.name }
      expect(response).to have_http_status(:ok)
    end

    context 'Access codes required' do
      before do
        allow_any_instance_of(Room).to receive(:viewer_access_code).and_return('AAA')
        allow_any_instance_of(Room).to receive(:moderator_access_code).and_return('BBB')
      end

      it 'joins as viewer if access code correspond to the viewer access code' do
        room = create(:room, user:)

        allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)
        expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Viewer')
        get :status, params: { friendly_id: room.friendly_id, name: user.name, access_code: 'AAA' }
        expect(response).to have_http_status(:ok)
      end

      it 'joins as moderator if access code correspond to moderator access code' do
        room = create(:room, user:)

        allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)
        expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Moderator')
        get :status, params: { friendly_id: room.friendly_id, name: user.name, access_code: 'BBB' }
        expect(response).to have_http_status(:ok)
      end

      it 'returns unauthorized if the access code is wrong' do
        room = create(:room, user:)

        allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)
        get :status, params: { friendly_id: room.friendly_id, name: user.name, access_code: 'ZZZ' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    it 'allows access to an unauthenticated user' do
      session[:user_id] = nil

      room = create(:room, user:)

      allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)
      expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Viewer')

      get :status, params: { friendly_id: room.friendly_id, name: user.name }

      expect(response).to have_http_status(:ok)
    end
  end

  private

  def meeting_starter_response
    {
      returncode: true,
      meetingID: 'hulsdzwvitlk1dbekzxdprshsxmvycvar0jeaszc',
      attendeePW: '12345',
      moderatorPW: '54321',
      createTime: 1_389_464_535_956,
      hasBeenForciblyEnded: false,
      messageKey: '',
      message: ''
    }
  end
end
