# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::UsersController, type: :controller do
  let(:user) { create(:user) }

  let(:manage_users_role) { create(:role) }
  let(:manage_users_permission) { create(:permission, name: 'ManageUsers') }
  let(:manage_users_role_permission) do
    create(:role_permission,
           role: manage_users_role,
           permission: manage_users_permission,
           value: 'true')
  end

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user.id
    manage_users_role_permission
    user.update!(role: manage_users_role)
  end

  describe '#active_users' do
    it 'ids of rooms in response are matching room ids that belong to current_user' do
      # TODO: Change this test to create active users and not just any users
      users = create_list(:user, 3)
      users << user

      get :active_users
      expect(response).to have_http_status(:ok)
      response_user_ids = JSON.parse(response.body)['data'].map { |user| user['id'] }
      expect(response_user_ids).to match_array(users.pluck(:id))
    end
  end
end
