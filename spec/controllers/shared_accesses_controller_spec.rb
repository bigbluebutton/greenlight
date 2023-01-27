# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SharedAccessesController, type: :controller do
  let(:user) { create(:user) }
  let(:room) { create(:room, user:) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    sign_in_user(user)
  end

  describe '#create' do
    it 'shares a room with a user' do
      new_user = create(:user)
      post :create, params: { friendly_id: room.friendly_id, shared_users: [new_user.id] }
      expect(new_user.shared_rooms).to include(room)
    end
  end

  describe '#destroy' do
    it 'unshares a room with a user' do
      new_user = create(:user)
      create(:shared_access, user_id: new_user.id, room_id: room.id)
      delete :destroy, params: { friendly_id: room.friendly_id, user_id: new_user.id }
      expect(new_user.shared_rooms).not_to include(room)
    end
  end

  describe '#show' do
    it 'returns all the users that the room has been shared to' do
      shared_users = create_list(:user, 5)
      unshared_users = create_list(:user, 5)
      room.shared_users = shared_users

      get :show, params: { friendly_id: room.friendly_id, search: '' }
      shared_user_ids = JSON.parse(response.body)['data'].map { |user| user['id'] }
      expect(shared_user_ids).to match_array(shared_users.pluck(:id))
      expect(shared_user_ids).not_to include(unshared_users.pluck(:id))
    end

    it 'returns the shared users according to the query' do
      room.shared_users = create_list(:user, 5)
      searched_users = create_list(:user, 5, name: 'John Doe')
      room.shared_users << searched_users

      get :show, params: { friendly_id: room.friendly_id, search: 'John Doe' }
      response_users_ids = JSON.parse(response.body)['data'].map { |user| user['id'] }
      expect(response_users_ids).to match_array(searched_users.pluck(:id))
    end

    it 'allows a shared user to view the shared access list' do
      shared_user = create(:user)
      sign_in_user(shared_user)

      shared_users = create_list(:user, 5)
      room.shared_users = shared_users + [shared_user]

      get :show, params: { friendly_id: room.friendly_id, search: '' }
      shared_user_ids = JSON.parse(response.body)['data'].map { |user| user['id'] }
      expect(shared_user_ids).to match_array((shared_users + [shared_user]).pluck(:id))
    end
  end

  describe '#shareable_users' do
    it 'returns an empty list if the search params is empty' do
      shareable_users = create_list(:user, 5, name: 'John Doe')
      shareable_users << user

      get :shareable_users, params: { friendly_id: room.friendly_id, search: '' }
      expect(JSON.parse(response.body)['data']).to be_empty
    end

    it 'does not return any users if the search params has less than 3 characters' do
      shareable_users = create_list(:user, 5, name: 'John Doe')
      shareable_users << user

      get :shareable_users, params: { friendly_id: room.friendly_id, search: 'Jo' }
      expect(JSON.parse(response.body)['data']).to be_empty
    end

    it 'returns the users that the room can be shared to' do
      room.shared_users = create_list(:user, 5)
      shareable_users = create_list(:user, 5, name: 'John Doe')

      get :shareable_users, params: { friendly_id: room.friendly_id, search: 'John Doe' }
      response_users_ids = JSON.parse(response.body)['data'].map { |user| user['id'] }
      expect(response_users_ids).to match_array(shareable_users.pluck(:id))
    end

    it 'returns the shareable users according to the query' do
      room.shared_users = create_list(:user, 5)
      shareable_users = create_list(:user, 5, name: 'Jane Doe')

      get :shareable_users, params: { friendly_id: room.friendly_id, search: 'Jane Doe' }
      response_users_ids = JSON.parse(response.body)['data'].map { |user| user['id'] }
      expect(response_users_ids).to match_array(shareable_users.pluck(:id))
    end

    context 'user without SharedList permission' do
      it 'does not return the users without SharedList permission' do
        room.shared_users = create_list(:user, 5)
        create(:user, :without_shared_list_permission, name: 'John Doe')

        get :shareable_users, params: { friendly_id: room.friendly_id, search: 'John Doe' }
        response_users_ids = JSON.parse(response.body)['data'].map { |user| user['id'] }
        expect(response_users_ids).to match_array([])
      end
    end
  end
end
