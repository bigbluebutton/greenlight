# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MeetingsController, type: :controller do
  let(:user) { create(:user) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user.id
  end

  describe '#start' do
    let(:room) { create(:room, user:) }

    before do
      allow_any_instance_of(BigBlueButtonApi)
        .to receive(:start_meeting)
        .and_return(true)
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
      ).and_call_original

      post :start, params: { friendly_id: room.friendly_id }
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
      ).and_call_original

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
      expect(JSON.parse(response.body)['data']['join_url']).to eq('https://example.com')
    end
  end

  describe '#join' do
    it 'calls the BigBlueButton service with the right values' do
      room = create(:room, user:)

      expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Viewer')
      get :join, params: { friendly_id: room.friendly_id, name: user.name }
    end

    it 'allows user to join if the access code is right' do
      room = create(:room, user:, viewer_access_code: 'AAA')

      get :join, params: { friendly_id: room.friendly_id, name: user.name, viewer_access_code: 'AAA' }
      expect(response).to have_http_status(:ok)
    end

    it 'refrain user from joining if the access code is wrong' do
      room = create(:room, user:, viewer_access_code: 'AAA')

      get :join, params: { friendly_id: room.friendly_id, name: user.name, viewer_access_code: 'BBB' }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe '#status' do
    it 'calls the BigBlueButton service with the right values' do
      room = create(:room, user:)

      expect_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).with(room:)

      get :status, params: { friendly_id: room.friendly_id, name: user.name }
    end

    it 'gets the joinUrl if the meeting is running' do
      room = create(:room, user:)

      allow_any_instance_of(BigBlueButtonApi).to receive(:meeting_running?).and_return(true)
      expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Viewer')

      get :status, params: { friendly_id: room.friendly_id, name: user.name }
    end

    it 'allows user to join if the access code is right' do
      room = create(:room, user:, viewer_access_code: 'AAA')

      get :status, params: { friendly_id: room.friendly_id, name: user.name, viewer_access_code: 'AAA' }
      expect(response).to have_http_status(:ok)
    end

    it 'refrain user from joining if the access code is wrong' do
      room = create(:room, user:, viewer_access_code: 'AAA')
      get :status, params: { friendly_id: room.friendly_id, name: user.name, viewer_access_code: 'BBB' }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
