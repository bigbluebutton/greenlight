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
      expect { post :create, params: user_params }.to change(User, :count).from(0).to(1)
      expect(response).to have_http_status(:created)
    end
  end
end
