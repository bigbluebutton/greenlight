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
<<<<<<< HEAD
      post :create, params: { friendly_id: room.friendly_id, room_id: room.id, users: [user.id] }
=======
      post :create, params: { room_id: room.id, users: [user.id] }
>>>>>>> 1c9b1dac... Backend: Add SharedAccess
      expect(user.shared_rooms).to include(room)
    end

    it "doesn't share a room with a user that it not selected" do
      room = create(:room)
      user = create(:user)
      random_user = create(:user)
<<<<<<< HEAD
      post :create, params: { friendly_id: room.friendly_id, room_id: room.id, users: [random_user.id] }
=======
      post :create, params: { room_id: room.id, users: [random_user.id] }
>>>>>>> 1c9b1dac... Backend: Add SharedAccess
      expect(user.shared_rooms).not_to include(room)
    end

    it "cannot share the room to the room's owner" do
      user = create(:user)
      room = create(:room, user:)
<<<<<<< HEAD
      post :create, params: { friendly_id: room.friendly_id, room_id: room.id, users: [user.id] }
=======
      post :create, params: { room_id: room.id, users: [user.id] }
>>>>>>> 1c9b1dac... Backend: Add SharedAccess
      expect(user.shared_rooms).not_to include(room)
    end
  end

  describe '#destroy' do
    it 'unshares a room with a user' do
      room = create(:room)
      user = create(:user)
      create(:shared_access, user_id: user.id, room_id: room.id)
<<<<<<< HEAD
      delete :destroy, params: { friendly_id: room.friendly_id, room_id: room.id, user_id: user.id }
=======
      delete :destroy, params: { room_id: room.id, user_id: user.id }
>>>>>>> 1c9b1dac... Backend: Add SharedAccess
      expect(user.shared_rooms).not_to include(room)
    end

    it "doesn't unshare a room with a user that is not selected" do
      room = create(:room)
      user = create(:user)
      random_user = create(:user)
      create(:shared_access, user_id: user.id, room_id: room.id)
      create(:shared_access, user_id: random_user.id, room_id: room.id)
<<<<<<< HEAD
      delete :destroy, params: { friendly_id: room.friendly_id, room_id: room.id, user_id: random_user.id }
=======
      delete :destroy, params: { room_id: room.id, user_id: random_user.id }
>>>>>>> 1c9b1dac... Backend: Add SharedAccess
      expect(user.shared_rooms).to include(room)
    end
  end

  describe '#shared_users' do
    it 'lists the users that the room has been shared to' do
      room = create(:room)
      users = create_list(:user, 10)
      shared_users = []

      users[0..4].each do |user|
        create(:shared_access, user_id: user.id, room_id: room.id)
        shared_users << user
      end

<<<<<<< HEAD
      get :shared_users, params: { friendly_id: room.friendly_id }
=======
      get :shared_users, params: { room_id: room.id }
>>>>>>> 1c9b1dac... Backend: Add SharedAccess
      shared_user_response = JSON.parse(response.body)['data'].map { |user| user['id'] }
      expect(shared_user_response).to eql(shared_users.pluck(:id))
    end
  end

  describe '#shareable_users' do
    it 'lists the users that the room can be shared to' do
      room = create(:room)
      users = create_list(:user, 10)
      shareable_users = []

      users[0..4].each do |user|
        create(:shared_access, user_id: user.id, room_id: room.id)
      end

      users[5..9].each do |user|
        shareable_users << user
      end

<<<<<<< HEAD
      get :shareable_users, params: { friendly_id: room.friendly_id }
=======
      get :shareable_users, params: { room_id: room.id }
>>>>>>> 1c9b1dac... Backend: Add SharedAccess
      shareable_user_response = JSON.parse(response.body)['data'].map { |user| user['id'] }
      expect(shareable_user_response).to eql(shareable_users.pluck(:id))
    end
  end
end
