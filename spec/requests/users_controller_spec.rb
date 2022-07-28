# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let(:valid_user_params) do
    {
      user: {
        name: Faker::Name.name,
        email: Faker::Internet.email,
        password: 'Password123+',
        password_confirmation: 'Password123+',
        language: 'language'
      }
    }
  end
  # TODO: Migrate this to controllers spec and refactor it for consistency.

  describe 'Signup' do
    let(:headers) { { 'ACCEPT' => 'application/json' } }

    context 'valid user params' do
      let!(:role) { create(:role, name: 'User') }

      it 'creates a user account for valid params' do
        expect { post api_v1_users_path, params: valid_user_params, headers: }.to change(User, :count).from(0).to(1)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['errors']).to be_nil
      end

      it 'generates an activation token for the user' do
        freeze_time

        post api_v1_users_path, params: valid_user_params, headers: headers
        user = User.find_by email: valid_user_params[:user][:email]
        expect(user.activation_digest).to be_present
        expect(user.activation_sent_at).to eq(Time.current)
        expect(user).not_to be_active
      end

      it 'assigns the User role to the user' do
        post api_v1_users_path, params: valid_user_params, headers: headers
        expect(User.find_by(email: valid_user_params[:user][:email]).role).to eq(role)
      end

      context 'User language' do
        it 'Persists the user language in the user record' do
          post api_v1_users_path, params: valid_user_params, headers: headers
          expect(User.find_by(email: valid_user_params[:user][:email]).language).to eq('language')
        end

        it 'defaults user language to default_locale if the language isn\'t specified' do
          allow(I18n).to receive(:default_locale).and_return(:default_language)
          valid_user_params[:user][:language] = nil
          post api_v1_users_path, params: valid_user_params, headers: headers
          expect(User.find_by(email: valid_user_params[:user][:email]).language).to eq('default_language')
        end
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

    context 'Role mapping' do
      before do
        setting = create(:setting, name: 'RoleMapping')
        create(:site_setting, setting:, provider: 'greenlight', value: 'Decepticons=@decepticons.cybertron,Autobots=autobots.cybertron')
      end

      it 'Creates a User and assign a role if a rule matches their email' do
        autobots = create(:role, name: 'Autobots')
        user_params = {
          name: 'Optimus Prime',
          email: 'optimus@autobots.cybertron',
          password: 'Autobots',
          password_confirmation: 'Autobots',
          language: 'teletraan'
        }

        expect { post api_v1_users_path, params: { user: user_params }, headers: }.to change(User, :count).from(0).to(1)
        expect(User.take.role).to eq(autobots)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['errors']).to be_nil
      end
    end
  end
end
