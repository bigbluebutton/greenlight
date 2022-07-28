# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::UsersController, type: :controller do
  let(:user) { create(:user) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user.id
  end

  describe '#active_users' do
    it 'ids of rooms in response are matching room ids that belong to current_user' do
      # TODO: Change this test to create active users and not just any users
      users = create_list(:user, 5)
      users << user

      get :active_users
      expect(response).to have_http_status(:ok)
      response_user_ids = JSON.parse(response.body)['data'].map { |user| user['id'] }
      expect(response_user_ids).to match_array(users.pluck(:id))
    end
  end

  describe '#create' do
    let(:user_params) do
      {
        user: { name: Faker::Name.name, email: Faker::Internet.email, password: Faker::Internet.password }
      }
    end

    it 'admin creates a user' do
      create(:role, name: 'User')
      expect { post :create, params: user_params }.to change(User, :count).by(1)
      expect(response).to have_http_status(:created)
    end
  end

  describe '#create_server_room' do
    it 'creates a room for a user if params are valid' do
      user = create(:user)
      room_valid_params = { name: 'Awesome Room' }
      expect { post :create_server_room, params: { user_id: user.id, room: room_valid_params } }.to(change { user.rooms.count })

      expect(response).to have_http_status(:created)
    end

    it 'returns :not_found for unfound users' do
      room_valid_params = { name: 'Awesome Room' }
      post :create_server_room, params: { user_id: 404, room: room_valid_params }

      expect(response).to have_http_status(:not_found)
    end

    it 'returns :bad_request for invalid params' do
      user = create(:user)

      post :create_server_room, params: { user_id: user.id, not_room: {} }

      expect(response).to have_http_status(:bad_request)
    end
  end
end
