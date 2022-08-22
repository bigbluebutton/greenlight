# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:user_with_manage_users_permission) { create(:user, :with_manage_users_permission) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user_with_manage_users_permission.id
  end

  describe '#active_users' do
    it 'returns the list of active users' do
      # TODO: this test doesnt test anything
      # TODO: active, banned, etc users feature has not been implemented yet (19.08)
      # TODO: Change this test to return active users and not just any users
      users = User.all

      get :active_users
      expect(response).to have_http_status(:ok)
      response_user_ids = JSON.parse(response.body)['data'].map { |user| user['id'] }
      expect(response_user_ids).to match_array(users.pluck(:id))
    end

    it 'excludes users with a different provider' do
      greenlight_users = create_list(:user, 3, provider: 'greenlight')
      greenlight_users << user_with_manage_users_permission

      create(:user, provider: 'test')

      get :active_users

      expect(JSON.parse(response.body)['data'].pluck('id')).to match_array(greenlight_users.pluck(:id))
    end
  end
end
