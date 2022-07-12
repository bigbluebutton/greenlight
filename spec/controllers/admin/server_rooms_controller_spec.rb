# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::ServerRoomsController, type: :controller do
  before do
    request.headers['ACCEPT'] = 'application/json'
  end

  describe '#index' do
    it 'returns all the Server Rooms' do
      user_one = create(:user)
      user_two = create(:user)

      user_one_rooms = create_list(:room, 5, user_id: user_one.id)
      user_two_rooms = create_list(:room, 5, user_id: user_two.id)
      rooms = user_one_rooms + user_two_rooms

      get :index
      response_room_ids = JSON.parse(response.body)['data'].map { |room| room['friendly_id'] }
      expect(response_room_ids).to match_array(rooms.pluck(:friendly_id))
    end
  end

  describe '#destroy' do
    it 'removes a given room for valid params' do
      room = create(:room)
      expect { delete :destroy, params: { friendly_id: room.friendly_id } }.to change(Room, :count).from(1).to(0)
      expect(response).to have_http_status(:ok)
    end

    it 'returns :not_found for not found rooms' do
      delete :destroy, params: { friendly_id: 'NOT_FRIENDLY_ANYMORE' }
      expect(response).to have_http_status(:not_found)
    end
  end
end
