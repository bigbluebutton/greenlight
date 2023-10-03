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

RSpec.describe Api::V1::MeetingsController, type: :controller do
  let(:user) { create(:user) }
  let(:guest_user) { create(:user) }
  let(:room) { create(:room, user:) }
  let(:test_user) { create(:user) }
  let(:test_room) { create(:room, user: test_user) }
  let(:user_with_manage_rooms_permission) { create(:user, :with_manage_rooms_permission) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    sign_in_user(user)

    allow_any_instance_of(BigBlueButtonApi)
      .to receive(:start_meeting)
      .and_return(meeting_starter_response)

    allow_any_instance_of(BigBlueButtonApi)
      .to receive(:join_meeting)
      .and_return('JOIN_URL')
  end

  describe '#start' do
    it 'makes a call to the MeetingStarter service with the right values and returns the join url' do
      expect(MeetingStarter).to receive(:new).with(room:, base_url: request.base_url, current_user: user, provider: 'greenlight').and_call_original
      expect_any_instance_of(MeetingStarter).to receive(:call)
      expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, avatar_url: nil, role: 'Moderator')

      post :start, params: { friendly_id: room.friendly_id }

      expect(response).to have_http_status(:created)
      expect(response.parsed_body['data']).to eq('JOIN_URL')
    end

    it 'cannot make call to MeetingStarter service for another room' do
      new_user = create(:user)
      new_room = create(:room, user: new_user)
      post :start, params: { friendly_id: new_room.friendly_id }
      expect(response).to have_http_status(:forbidden)
    end

    it 'makes a call to the BigBlueButtonApi to get the join url' do
      expect_any_instance_of(BigBlueButtonApi)
        .to receive(:join_meeting)
        .with(room:, name: user.name, avatar_url: nil, role: 'Moderator')

      post :start, params: { friendly_id: room.friendly_id }
    end

    it 'passes the users avatar (if they have one) to BigBlueButton' do
      user.avatar.attach(io: fixture_file_upload('default-avatar.png'), filename: 'default-avatar.png', content_type: 'image/png')
      avatar_url = Rails.application.routes.url_helpers.rails_blob_url(user.avatar, host: 'test.host')

      expect_any_instance_of(BigBlueButtonApi)
        .to receive(:join_meeting)
        .with(room:, name: user.name, avatar_url:, role: 'Moderator')

      post :start, params: { friendly_id: room.friendly_id }
    end

    it 'returns the join url to the front-end for redirecting' do
      post :start, params: { friendly_id: room.friendly_id }

      expect(response).to have_http_status(:created)
      expect(response.parsed_body['data']).to eq('JOIN_URL')
    end

    it 'returns an error if the user is not logged in' do
      session[:session_token] = nil

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
        expect(response.parsed_body['data']).to eq('JOIN_URL')
      end
    end

    context 'user with ManageRooms permission' do
      before do
        sign_in_user(user_with_manage_rooms_permission)
      end

      it 'makes a call to MeetingStarter service for another room' do
        new_user = create(:user)
        new_room = create(:room, user: new_user)
        post :start, params: { friendly_id: new_room.friendly_id }
        expect(response).to have_http_status(:created)
      end
    end

    context 'SharedRoom' do
      before do
        guest_user.shared_rooms << room
        sign_in_user(guest_user)
      end

      it 'allows a user who the room is shared with to start the meeting' do
        expect_any_instance_of(MeetingStarter).to receive(:call)
        expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: guest_user.name, avatar_url: nil, role: 'Moderator')

        post :start, params: { friendly_id: room.friendly_id }

        expect(response).to have_http_status(:created)
        expect(response.parsed_body['data']).to eq('JOIN_URL')
      end
    end
  end

  describe '#status' do
    it 'gets the joinUrl if the meeting is running' do
      allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)
      expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room: test_room, name: user.name, avatar_url: nil, role: 'Viewer')

      post :status, params: { friendly_id: test_room.friendly_id, name: user.name }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data']).to eq({ 'joinUrl' => 'JOIN_URL', 'status' => true })
    end

    it 'returns status false if the meeting is NOT running and the user is NOT authorized to start the meeting' do
      allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(false)
      expect_any_instance_of(BigBlueButtonApi).not_to receive(:join_meeting)

      post :status, params: { friendly_id: test_room.friendly_id, name: user.name }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data']).to eq({ 'status' => false })
    end

    it 'joins as viewer if no access code is required nor provided' do
      allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)
      expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room: test_room, name: user.name, avatar_url: nil, role: 'Viewer')
      post :status, params: { friendly_id: test_room.friendly_id, name: user.name }
      expect(response).to have_http_status(:ok)
    end

    it 'joins as moderator if user is joining his own room' do
      allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)
      expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, avatar_url: nil, role: 'Moderator')
      post :status, params: { friendly_id: room.friendly_id, name: user.name }
      expect(response).to have_http_status(:ok)
    end

    it 'passes the users avatar (if they have one) to BigBlueButton' do
      allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)
      user.avatar.attach(io: fixture_file_upload('default-avatar.png'), filename: 'default-avatar.png', content_type: 'image/png')
      avatar_url = Rails.application.routes.url_helpers.rails_blob_url(user.avatar, host: 'test.host')

      expect_any_instance_of(BigBlueButtonApi)
        .to receive(:join_meeting)
        .with(room: test_room, name: user.name, avatar_url:, role: 'Viewer')

      post :status, params: { friendly_id: test_room.friendly_id, name: user.name }
    end

    it 'starts the meeting if the user is a moderator' do
      allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(false)
      expect_any_instance_of(MeetingStarter).to receive(:call)

      post :status, params: { friendly_id: room.friendly_id, name: user.name }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data']).to eq({ 'joinUrl' => 'JOIN_URL', 'status' => true })
    end

    context 'user is joining a shared room' do
      before do
        guest_user.shared_rooms << room
        sign_in_user(guest_user)
      end

      it 'joins as moderator' do
        allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)
        expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: guest_user.name, avatar_url: nil, role: 'Moderator')
        post :status, params: { friendly_id: room.friendly_id, name: guest_user.name }
      end
    end

    context 'Access codes required' do
      let(:fake_room_settings_getter) { instance_double(RoomSettingsGetter) }

      before do
        allow(RoomSettingsGetter).to receive(:new).and_return(fake_room_settings_getter)
        allow(fake_room_settings_getter).to receive(:call).and_return({ 'glViewerAccessCode' => 'AAA', 'glModeratorAccessCode' => 'BBB' })
      end

      it 'joins as viewer if access code correspond to the viewer access code' do
        allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)

        expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room: test_room, name: user.name, avatar_url: nil, role: 'Viewer')
        expect(RoomSettingsGetter).to receive(:new).with(
          room_id: test_room.id, provider: 'greenlight', show_codes: true, current_user: user,
          settings: %w[glRequireAuthentication glViewerAccessCode glModeratorAccessCode glAnyoneCanStart glAnyoneJoinAsModerator]
        )
        expect(fake_room_settings_getter).to receive(:call)

        post :status, params: { friendly_id: test_room.friendly_id, name: user.name, access_code: 'AAA' }

        expect(response).to have_http_status(:ok)
      end

      it 'joins as moderator if access code correspond to moderator access code' do
        allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)

        expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, avatar_url: nil, role: 'Moderator')
        expect(RoomSettingsGetter).to receive(:new).with(
          room_id: room.id, provider: 'greenlight', show_codes: true, current_user: user,
          settings: %w[glRequireAuthentication glViewerAccessCode glModeratorAccessCode glAnyoneCanStart glAnyoneJoinAsModerator]
        )
        expect(fake_room_settings_getter).to receive(:call)

        post :status, params: { friendly_id: room.friendly_id, name: user.name, access_code: 'BBB' }

        expect(response).to have_http_status(:ok)
      end

      it 'returns unauthorized if the access code is wrong' do
        allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)

        expect(RoomSettingsGetter).to receive(:new).with(
          room_id: test_room.id, provider: 'greenlight', show_codes: true, current_user: user,
          settings: %w[glRequireAuthentication glViewerAccessCode glModeratorAccessCode glAnyoneCanStart glAnyoneJoinAsModerator]
        )
        expect(fake_room_settings_getter).to receive(:call)

        post :status, params: { friendly_id: test_room.friendly_id, name: user.name, access_code: 'ZZZ' }

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'glAnyoneJoinAsModerator is true' do
      let(:fake_room_settings_getter) { instance_double(RoomSettingsGetter) }

      before do
        sign_in_user(guest_user)
        allow(RoomSettingsGetter).to receive(:new).and_return(fake_room_settings_getter)
        allow(fake_room_settings_getter).to receive(:call).and_return({ 'glAnyoneJoinAsModerator' => 'true' })
      end

      it 'user joins as a moderator' do
        allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)

        expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: guest_user.name, avatar_url: nil, role: 'Moderator')
        expect(RoomSettingsGetter).to receive(:new).with(
          room_id: room.id, provider: 'greenlight', show_codes: true, current_user: guest_user,
          settings: %w[glRequireAuthentication glViewerAccessCode glModeratorAccessCode glAnyoneCanStart glAnyoneJoinAsModerator]
        )
        expect(fake_room_settings_getter).to receive(:call)

        post :status, params: { friendly_id: room.friendly_id, name: guest_user.name }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'glAnyoneJoinAsModerator is true and an access code is required' do
      let(:fake_room_settings_getter) { instance_double(RoomSettingsGetter) }

      before do
        sign_in_user(guest_user)
        allow(RoomSettingsGetter).to receive(:new).and_return(fake_room_settings_getter)
        allow(fake_room_settings_getter).to receive(:call)
          .and_return({ 'glAnyoneJoinAsModerator' => 'true', 'glViewerAccessCode' => 'AAA', 'glModeratorAccessCode' => 'BBB' })
      end

      it 'user joins as moderator if an access code is needed and the input correspond the viewer access code' do
        allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)

        expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: guest_user.name, avatar_url: nil, role: 'Moderator')
        expect(RoomSettingsGetter).to receive(:new).with(
          room_id: room.id, provider: 'greenlight', show_codes: true, current_user: guest_user,
          settings: %w[glRequireAuthentication glViewerAccessCode glModeratorAccessCode glAnyoneCanStart glAnyoneJoinAsModerator]
        )
        expect(fake_room_settings_getter).to receive(:call)

        post :status, params: { friendly_id: room.friendly_id, name: guest_user.name, access_code: 'AAA' }

        expect(response).to have_http_status(:ok)
      end

      it 'user joins as moderator if an access code is needed and the input correspond the moderator access code' do
        allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)

        expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: guest_user.name, avatar_url: nil, role: 'Moderator')
        expect(RoomSettingsGetter).to receive(:new).with(
          room_id: room.id, provider: 'greenlight', show_codes: true, current_user: guest_user,
          settings: %w[glRequireAuthentication glViewerAccessCode glModeratorAccessCode glAnyoneCanStart glAnyoneJoinAsModerator]
        )
        expect(fake_room_settings_getter).to receive(:call)

        post :status, params: { friendly_id: room.friendly_id, name: guest_user.name, access_code: 'BBB' }

        expect(response).to have_http_status(:ok)
      end

      it 'returns unauthorized if a moderator or a viewer access code is required and the input correspond to neither' do
        allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)

        expect(RoomSettingsGetter).to receive(:new).with(
          room_id: room.id, provider: 'greenlight', show_codes: true, current_user: guest_user,
          settings: %w[glRequireAuthentication glViewerAccessCode glModeratorAccessCode glAnyoneCanStart glAnyoneJoinAsModerator]
        )
        expect(fake_room_settings_getter).to receive(:call)

        post :status, params: { friendly_id: room.friendly_id, name: guest_user.name, access_code: 'ZZZ' }

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

        expect(MeetingStarter).to receive(:new).with(room:, base_url: request.base_url, current_user: user, provider: 'greenlight').and_call_original
        expect_any_instance_of(MeetingStarter).to receive(:call)

        post :status, params: { friendly_id: room.friendly_id, name: user.name }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['data']).to eq({ 'joinUrl' => 'JOIN_URL', 'status' => true })
      end

      it 'doesnt start the meeting if its already running' do
        request.env['HTTP_REFERER'] = 'http://example.com'

        allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)

        expect_any_instance_of(MeetingStarter).not_to receive(:call)

        post :status, params: { friendly_id: room.friendly_id, name: user.name }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['data']).to eq({ 'joinUrl' => 'JOIN_URL', 'status' => true })
      end
    end

    context 'glRequireAuthentication' do
      let(:fake_room_settings_getter) { instance_double(RoomSettingsGetter) }

      before do
        allow(RoomSettingsGetter).to receive(:new).and_return(fake_room_settings_getter)
        allow(fake_room_settings_getter).to receive(:call).and_return({ 'glRequireAuthentication' => 'true' })
      end

      it 'allows the user to join if they are signed in' do
        allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)
        expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room: test_room, name: user.name, avatar_url: nil, role: 'Viewer')

        post :status, params: { friendly_id: test_room.friendly_id, name: user.name }

        expect(response).to have_http_status(:ok)
      end

      it 'returns unauthorized if the user isnt signed in' do
        session[:session_token] = nil

        expect_any_instance_of(BigBlueButtonApi).not_to receive(:join_meeting)

        post :status, params: { friendly_id: room.friendly_id, name: user.name }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    it 'allows access to an unauthenticated user' do
      session[:session_token] = nil

      allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)
      expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, avatar_url: nil, role: 'Viewer')

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
