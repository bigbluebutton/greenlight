# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::RoomsController, type: :request do
  before do
  end
  # TODO: Hadi - Make test work with current_user
  describe 'index' do
    let(:headers) { { 'ACCEPT' => 'application/json' } }
    context 'gets rooms that belong to current user' do
      it 'checks if ids of rooms in response are matching room ids that belong to current_user ' do
        rooms = create_list(:room, 5)
        list_room_ids = rooms.pluck(:id)
        expect { get '/api/v1/rooms.json', headers: }.not_to change(Room, :count)
        expect(response).to have_http_status(:ok)
        response_room_ids = JSON.parse(response.body)['data'].map { |room| room['id']}
        expect(list_room_ids).to eq(response_room_ids)
      end
    end
  end
end
