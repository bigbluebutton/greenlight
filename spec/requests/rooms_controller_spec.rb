# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::RoomsController, type: :request do
  before do
  end
  # TODO: Hadi - Make test work with current_user
  describe 'index' do
    let(:headers) { { 'ACCEPT' => 'application/json' } }
    it 'ids of rooms in response are matching room ids that belong to current_user' do
      rooms = create_list(:room, 5)
      list_room_ids = rooms.pluck(:id)
      get api_v1_rooms_path(), headers: headers
      expect(response).to have_http_status(:ok)
      response_room_ids = JSON.parse(response.body)['data'].map { |room| room['id']}
      expect(response_room_ids).to eq(list_room_ids)
    end

    it 'no rooms for current_user should return empty list' do
      get api_v1_rooms_path(), headers: headers
      expect(response).to have_http_status(:ok)
      response_room_ids = JSON.parse(response.body)['data'].map { |room| room['id']}
      expect(response_room_ids).to eq([])
    end
  end
end
