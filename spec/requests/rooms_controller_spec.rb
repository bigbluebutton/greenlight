# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::RoomsController, type: :request do
  let(:headers) { { 'ACCEPT' => 'application/json' } } # TODO: Ahmad - move this to rails_helper

  # TODO: Hadi - Make test work with current_user
  describe 'index' do
    it 'ids of rooms in response are matching room ids that belong to current_user' do
      rooms = create_list(:room, 5)
      get api_v1_rooms_path, headers: headers
      expect(response).to have_http_status(:ok)
      response_room_ids = JSON.parse(response.body)['data'].map { |room| room['id']}
      expect(response_room_ids).to eq(rooms.pluck(:id))
    end

    it 'no rooms for current_user should return empty list' do
      get api_v1_rooms_path, headers: headers
      expect(response).to have_http_status(:ok)
      response_room_ids = JSON.parse(response.body)['data'].map { |room| room['id']}
      expect(response_room_ids).to be_empty
    end
  end

  describe '#show' do
    it 'returns a room if the friendly id is valid' do
      room = create(:room)
      get api_v1_room_path(friendly_id: room.friendly_id), headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq(room.id)
    end

    it 'returns not_found if the room doesnt exist' do
      get api_v1_room_path(friendly_id: 'invalid_friendly_id'), headers: headers
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['data']).to be_empty
    end
  end
end
