# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::RoomsController, type: :controller do
  let(:user) { create(:user) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user.id
  end

  describe 'index' do
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

    it 'returns not_found if the room doesnt exist' do
      get :show, params: { friendly_id: 'invalid_friendly_id' }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['data']).to be_empty
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

    it 'returns not_found if the room doesn\'t exist' do
      post :start, params: { friendly_id: 'invalid_friendly_id' }
      expect(response).to have_http_status(:not_found)
    end
  end
end
