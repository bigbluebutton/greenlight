# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:user_with_manage_users_permission) { create(:user, :with_manage_users_permission) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    sign_in_user(user_with_manage_users_permission)
  end

  describe '#verified_users' do
    it 'returns the list of active users' do
      # TODO: this test doesnt test anything
      # TODO: active, banned, etc users feature has not been implemented yet (19.08)
      # TODO: Change this test to return active users and not just any users
      users = User.all

      get :verified_users
      expect(response).to have_http_status(:ok)
      response_user_ids = JSON.parse(response.body)['data'].map { |user| user['id'] }
      expect(response_user_ids).to match_array(users.pluck(:id))
    end

    it 'excludes users with a different provider' do
      greenlight_users = create_list(:user, 3, provider: 'greenlight')
      greenlight_users << user_with_manage_users_permission
      role_with_provider_test = create(:role, provider: 'test')
      create(:user, provider: 'test', role: role_with_provider_test)

      get :verified_users

      expect(JSON.parse(response.body)['data'].pluck('id')).to match_array(greenlight_users.pluck(:id))
    end
  end

  describe '#pending' do
    it 'returns a list of pending users' do
      users = create_list(:user, 3, status: 'pending')

      get :pending

      expect(JSON.parse(response.body)['data'].pluck('id')).to match_array(users.pluck(:id))
    end

    context 'user without ManageUsers permission' do
      before do
        sign_in_user(user)
      end

      it 'returns :forbidden for user without ManageUsers permission' do
        get :pending
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe '#update' do
    it 'updates a users status' do
      post :update, params: { id: user.id, user: { status: 'banned' } }

      expect(user.reload.status).to eq('banned')
    end

    context 'user without ManageUsers permission' do
      before do
        sign_in_user(user)
      end

      it 'returns :forbidden for user without ManageUsers permission' do
        post :update, params: { id: user.id, user: { status: 'banned' } }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
