# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::RoomsController, type: :controller do
  let(:user) { create(:user) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user.id
  end

  describe '#index' do
    it 'ids of rooms in response are matching room ids that belong to current_user' do
      rooms = create_list(:room, 5, user:)
      get :index
      expect(response).to have_http_status(:ok)
      response_room_ids = JSON.parse(response.body)['data'].map { |room| room['id'] }
      expect(response_room_ids).to eq(rooms.pluck(:id))
    end

    it 'no rooms for current_user should return empty list' do
      get :index
      expect(response).to have_http_status(:ok)
      response_room_ids = JSON.parse(response.body)['data'].map { |room| room['id'] }
      expect(response_room_ids).to be_empty
    end
  end

  describe '#show' do
    it 'returns a room if the friendly id is valid' do
      room = create(:room, user:)
      get :show, params: { friendly_id: room.friendly_id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq(room.id)
    end

    it 'returns :not_found if the room doesnt exist' do
      get :show, params: { friendly_id: 'invalid_friendly_id' }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['data']).to be_empty
    end
  end

  describe '#destroy' do
    it 'deletes room from the database' do
      room = create(:room, user:)
      expect { delete :destroy, params: { friendly_id: room.friendly_id } }.to change(Room, :count).by(-1)
    end

    it 'deletes the recordings associated with the room' do
      room = create(:room, user:)
      create_list(:recording, 10, room:)
      expect { delete :destroy, params: { friendly_id: room.friendly_id } }.to change(Recording, :count).by(-10)
    end
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

      expect(MeetingStarter).to receive(:new).with(room:, logout_url: logout)

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

  describe '#create' do
    let(:room_params) do
      {
        room: { name: Faker::Science.science }
      }
    end

    it 'creates a room for the authenticated user' do
      session[:user_id] = user.id
      expect { post :create, params: room_params }.to change { user.rooms.count }.from(0).to(1)
      expect(response).to have_http_status(:created)
    end
  end

  describe '#recordings' do
    it 'returns recordings belonging to the room' do
      room1 = create(:room, user:, friendly_id: 'friendly_id_1')
      room2 = create(:room, user:, friendly_id: 'friendly_id_2')
      recordings = create_list(:recording, 5, room: room1)
      create_list(:recording, 5, room: room2)
      get :recordings, params: { friendly_id: room1.friendly_id }
      recording_ids = JSON.parse(response.body)['data'].map { |recording| recording['id'] }
      expect(response).to have_http_status(:ok)
      expect(recording_ids).to eq(recordings.pluck(:id))
    end

    it 'returns an empty array if the room has no recordings' do
      room1 = create(:room, user:, friendly_id: 'friendly_id_1')
      get :recordings, params: { friendly_id: room1.friendly_id }
      recording_ids = JSON.parse(response.body)['data'].map { |recording| recording['id'] }
      expect(response).to have_http_status(:ok)
      expect(recording_ids).to be_empty
    end
  end

  describe '#join' do
    it 'calls the BigBlueButton service with the right values' do
      room = create(:room, user:)

      expect_any_instance_of(BigBlueButtonApi).to receive(:join_meeting).with(room:, name: user.name, role: 'Viewer')
      get :join, params: { friendly_id: room.friendly_id, name: user.name }
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
  end
end
