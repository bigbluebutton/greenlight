# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MeetingsController, type: :controller do
  let(:user) { create(:user) }
  let(:room) { create(:room, user:) }
  let(:user_with_manage_rooms_permission) { create(:user, :with_manage_rooms_permission) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user.id

    allow_any_instance_of(BigBlueButtonApi)
      .to receive(:start_meeting)
      .and_return(meeting_starter_response)

    allow_any_instance_of(BigBlueButtonApi)
      .to receive(:join_meeting)
      .and_return('JOIN_URL')
  end

  describe '#start' do
    it 'makes a call to the MeetingStarter service with the right values and returns the join url' do
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
        recording_ready: recording_ready_url,
        current_user: user,
        provider: 'greenlight'
      ).and_call_original

      expect_any_instance_of(MeetingStarter).to receive(:call)
      expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Moderator')

      post :start, params: { friendly_id: room.friendly_id }

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['data']).to eq('JOIN_URL')
    end

    it 'cannot make call to MeetingStarter service for another room' do
      new_user = create(:user)
      new_room = create(:room, user: new_user)
      post :start, params: { friendly_id: new_room.friendly_id }
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
        recording_ready: recording_ready_url,
        current_user: user,
        provider: 'greenlight'
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
      post :start, params: { friendly_id: room.friendly_id }

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['data']).to eq('JOIN_URL')
    end

    it 'returns an error if the user is not logged in' do
      session[:user_id] = nil

      post :start, params: { friendly_id: room.friendly_id }

      expect(response).to have_http_status(:unauthorized)
    end

    context 'idNotUnique' do
      it 'still returns the join url if the error returned is idNotUnique' do
        exception = BigBlueButton::BigBlueButtonException.new('idNotUnique')
        exception.key = 'idNotUnique'

        allow_any_instance_of(MeetingStarter)
          .to receive(:call)
          .and_raise(exception)

        post :start, params: { friendly_id: room.friendly_id }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']).to eq('JOIN_URL')
      end
    end

    context 'user with ManageRooms permission' do
      before do
        session[:user_id] = user_with_manage_rooms_permission.id
      end

      it 'makes a call to MeetingStarter service for another room' do
        new_user = create(:user)
        new_room = create(:room, user: new_user)
        post :start, params: { friendly_id: new_room.friendly_id }
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe '#status' do
    it 'gets the joinUrl if the meeting is running' do
      allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)
      expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Viewer')

      post :status, params: { friendly_id: room.friendly_id, name: user.name }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']).to eq({ 'joinUrl' => 'JOIN_URL', 'status' => true })
    end

    it 'returns status false if the meeting is NOT running' do
      allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(false)
      expect_any_instance_of(BigBlueButtonApi).not_to receive(:join_meeting)

      post :status, params: { friendly_id: room.friendly_id, name: user.name }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']).to eq({ 'status' => false })
    end

    it 'joins as viewer if no access code is required nor provided' do
      allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)
      expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Viewer')
      post :status, params: { friendly_id: room.friendly_id, name: user.name }
      expect(response).to have_http_status(:ok)
    end

    context 'Access codes required' do
      let(:fake_room_settings_getter) { instance_double(RoomSettingsGetter) }

      before do
        allow(RoomSettingsGetter).to receive(:new).and_return(fake_room_settings_getter)
        allow(fake_room_settings_getter).to receive(:call).and_return({ 'glViewerAccessCode' => 'AAA', 'glModeratorAccessCode' => 'BBB' })
      end

      it 'joins as viewer if access code correspond to the viewer access code' do
        allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)

        expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Viewer')
        expect(RoomSettingsGetter).to receive(:new).with(room_id: room.id, provider: 'greenlight', show_codes: true, current_user: user,
                                                         settings: %w[glViewerAccessCode glModeratorAccessCode glAnyoneCanStart])
        expect(fake_room_settings_getter).to receive(:call)
        post :status, params: { friendly_id: room.friendly_id, name: user.name, access_code: 'AAA' }
        expect(response).to have_http_status(:ok)
      end

      it 'joins as moderator if access code correspond to moderator access code' do
        allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)

        expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Moderator')
        expect(RoomSettingsGetter).to receive(:new).with(room_id: room.id, provider: 'greenlight', show_codes: true, current_user: user,
                                                         settings: %w[glViewerAccessCode glModeratorAccessCode glAnyoneCanStart])
        expect(fake_room_settings_getter).to receive(:call)
        post :status, params: { friendly_id: room.friendly_id, name: user.name, access_code: 'BBB' }
        expect(response).to have_http_status(:ok)
      end

      it 'returns unauthorized if the access code is wrong' do
        allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)

        expect(RoomSettingsGetter).to receive(:new).with(room_id: room.id, provider: 'greenlight', show_codes: true, current_user: user,
                                                         settings: %w[glViewerAccessCode glModeratorAccessCode glAnyoneCanStart])
        expect(fake_room_settings_getter).to receive(:call)
        post :status, params: { friendly_id: room.friendly_id, name: user.name, access_code: 'ZZZ' }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'glAnyoneCanStart' do
      let(:fake_room_settings_getter) { instance_double(RoomSettingsGetter) }

      before do
        allow(RoomSettingsGetter).to receive(:new).and_return(fake_room_settings_getter)
        allow(fake_room_settings_getter).to receive(:call).and_return({ 'glAnyoneCanStart' => 'true' })
      end

      it 'starts the meeting if the meeting isnt already running' do
        request.env['HTTP_REFERER'] = 'http://example.com'

        allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(false)

        expect(
          MeetingStarter
        ).to receive(:new).with(
          room:,
          logout_url: 'http://example.com',
          presentation_url: nil,
          meeting_ended: meeting_ended_url,
          recording_ready: recording_ready_url,
          current_user: user,
          provider: 'greenlight'
        ).and_call_original

        expect_any_instance_of(MeetingStarter).to receive(:call)

        post :status, params: { friendly_id: room.friendly_id, name: user.name }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']).to eq({ 'joinUrl' => 'JOIN_URL', 'status' => true })
      end

      it 'doesnt start the meeting if its already running' do
        request.env['HTTP_REFERER'] = 'http://example.com'

        allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)

        expect_any_instance_of(MeetingStarter).not_to receive(:call)

        post :status, params: { friendly_id: room.friendly_id, name: user.name }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']).to eq({ 'joinUrl' => 'JOIN_URL', 'status' => true })
      end
    end

    it 'allows access to an unauthenticated user' do
      session[:user_id] = nil

      room = create(:room, user:)

      allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)
      expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Viewer')

      post :status, params: { friendly_id: room.friendly_id, name: user.name }

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
