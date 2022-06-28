# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::UsersController, type: :controller do
  before do
    request.headers['ACCEPT'] = 'application/json'
  end

  describe '#active_users' do
    it 'ids of rooms in response are matching room ids that belong to current_user' do
      # TODO: Change this test to create active users and not just any users
      users = create_list(:user, 5)
      get :active_users
      expect(response).to have_http_status(:ok)
      response_user_ids = JSON.parse(response.body)['data'].map { |user| user['id'] }
      expect(response_user_ids).to eq(users.pluck(:id))
    end
  end
end
