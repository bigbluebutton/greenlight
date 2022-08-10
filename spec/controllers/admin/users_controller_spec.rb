# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::UsersController, type: :controller do
  let(:role) { create(:role) }
  let(:user) { create(:user, role:) }
  let(:manage_users_permission) { create(:permission, name: 'ManageUsers') }
  let!(:manage_users_role_permission) do
    create(:role_permission,
           role_id: user.role_id,
           permission_id: manage_users_permission.id,
           value: 'true',
           provider: 'greenlight')
  end

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user.id
  end

  describe '#active_users' do
    it 'ids of rooms in response are matching room ids that belong to current_user' do
      # TODO: Change this test to create active users and not just any users
      users = create_list(:user, 3)
      users << user

      manage_users_role_permission

      get :active_users
      expect(response).to have_http_status(:ok)
      response_user_ids = JSON.parse(response.body)['data'].map { |user| user['id'] }
      expect(response_user_ids).to match_array(users.pluck(:id))
    end
  end
end
