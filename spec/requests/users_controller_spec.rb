# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let(:valid_user_params) do
    {
      user: {
        name: Faker::Name.name,
        email: Faker::Internet.email,
        password: 'Password123+',
        password_confirmation: 'Password123+'
      }
    }
  end

  describe 'Signup' do
    let(:headers) { { 'ACCEPT' => 'application/json' } }

    context 'valid user params' do
      it 'creates a user account for valid params' do
        expect { post api_v1_users_path, params: valid_user_params, headers: }.to change(User, :count).from(0).to(1)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['errors']).to be_empty
      end
    end

    context 'invalid user params' do
      it 'fails for invalid values' do
        invalid_user_params = {
          user: { name: '', email: 'invalid', password: 'something', password_confirmation: 'something_else' }
        }
        expect { post api_v1_users_path, params: invalid_user_params, headers: }.not_to change(User, :count)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end
end
