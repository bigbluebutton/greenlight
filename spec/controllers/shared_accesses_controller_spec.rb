# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SharedAccessesController, type: :controller do
  before do
    request.headers['ACCEPT'] = 'application/json'
  end

  describe '#create' do
    it 'shares a room with a user' do
      room = create(:room)
      user = create(:user)
      post :create, params: { friendly_id: room.friendly_id, users: { shared_users: [user.id] } }
      expect(user.shared_rooms).to include(room)
    end
  end

  describe '#destroy' do
    it 'unshares a room with a user' do
      room = create(:room)
      user = create(:user)
      create(:shared_access, user_id: user.id, room_id: room.id)
      delete :destroy, params: { friendly_id: room.friendly_id, user_id: user.id }
      expect(user.shared_rooms).not_to include(room)
    end
  end

  describe '#show' do
    it 'lists the users that the room has been shared to' do
      room = create(:room)
      shared_users = create_list(:user, 5)
      unshared_users = create_list(:user, 5)
      room.shared_users = shared_users

      get :show, params: { friendly_id: room.friendly_id }
      shared_user_ids = JSON.parse(response.body)['data'].map { |user| user['id'] }
      expect(shared_user_ids).to eql(shared_users.pluck(:id))
      expect(shared_user_ids).not_to include(unshared_users.pluck(:id))
    end
  end

  describe '#shareable_users' do
    it 'lists the users that the room can be shared to' do
      room = create(:room)
      shared_users = create_list(:user, 5)
      shareable_users = create_list(:user, 5)
      room.shared_users = shared_users

      get :shareable_users, params: { friendly_id: room.friendly_id }
      shareable_user_ids = JSON.parse(response.body)['data'].map { |user| user['id'] }
      expect(shareable_user_ids).to eql(shareable_users.pluck(:id))
    end
  end
end
