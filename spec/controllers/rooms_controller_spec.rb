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

  describe '#start_meeting' do
    let(:join_url) { 'https://test.com/bigbluebutton/api?join' }
    let(:bbb_service) { instance_double(BigBlueButtonApi) }

    before do
      allow(BigBlueButtonApi).to receive(:new).and_return(bbb_service)
      allow(bbb_service).to receive(:start_meeting).and_return(join_url)
    end

    it 'returns the join_url for existent room' do
      room = create(:room, user:)
      post :start, params: { friendly_id: room.friendly_id }
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['data']['join_url']).to eq(join_url)
    end

    it 'returns :not_found if the room doesn\'t exist' do
      post :start, params: { friendly_id: 'invalid_friendly_id' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe '#create' do
    require 'bigbluebutton_api'

    let(:to_be_accepted_options) do
      {
        option1: 'value1',
        option2: 'value2'
      }
    end

    let(:to_be_filtered_options) do
      {
        glJoinOnStart: 'false',
        something: 'something',
        something_else: 'something_else'
      }
    end

    let(:room_params) do
      options = to_be_accepted_options.merge to_be_filtered_options
      {
        room: {
          name: Faker::Science.science,
          options:
        }
      }
    end

    let(:bbb_server) { instance_double(BigBlueButton::BigBlueButtonApi) }

    before do
      create :meeting_option, name: 'option1'
      create :meeting_option, name: 'option2'
      create :meeting_option, name: 'option3'

      session[:user_id] = user.id

      allow(BigBlueButton::BigBlueButtonApi).to receive(:new).and_return(bbb_server)
      allow(bbb_server).to receive(:create_meeting).and_return(true)
      allow(bbb_server).to receive(:join_meeting_url).and_return('JOIN_URL')
    end

    it 'creates a room while filtering its meeting options for the authenticated user' do
      expect { post :create, params: room_params }.to change { user.rooms.count }.from(0).to(1)
      room = user.rooms.take
      room_meeting_option_values = room.room_meeting_options.pluck :value
      to_be_accepted_options_values = to_be_accepted_options.values
      expect(to_be_accepted_options_values - room_meeting_option_values).to be_empty
      expect(response).to have_http_status(:created)
    end

    it 'creates a room without starting a meeting if no options are set by the room creator' do
      bbb_service = instance_double(BigBlueButtonApi)
      allow(BigBlueButton::BigBlueButtonApi).to receive(:new).and_return(bbb_service)

      room_params[:room][:options] = nil
      expect { post :create, params: room_params }.to change { user.rooms.count }.from(0).to(1)
      room = user.rooms.take
      expect(room.room_meeting_options.count).to be_zero
      expect(response).to have_http_status(:created)
      expect(bbb_service).not_to receive(:start_meeting)
      expect(JSON.parse(response.body)['data']).to be_empty
    end

    skip 'returns :unauthorized for none authenticated users'

    describe 'join on start' do
      it 'starts and returns the join url if glJoinOnStart option is "true"' do
        room_params[:room][:options] = { glJoinOnStart: 'true' }
        post :create, params: room_params
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']['join_url']).to eq('JOIN_URL')
      end

      it 'doesn\'t start or return the join url if glJoinOnStart isn\'t "true"' do
        room_params[:room][:options] = { glJoinOnStart: 'something' }
        post :create, params: room_params
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']).to be_empty
      end

      it 'doesn\'t start or return the join url if glJoinOnStart isn\'t set' do
        room_params[:room][:options] = { other: 'other' }
        post :create, params: room_params
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['data']).to be_empty
      end
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
end
