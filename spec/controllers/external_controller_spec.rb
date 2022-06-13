# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalController, type: :controller do
  before do
    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[:openid_connect] = OmniAuth::AuthHash.new(
      uid: Faker::Internet.uuid,
      info: {
        email: Faker::Internet.email,
        name: Faker::Name.name
      }
    )
  end

  describe '#create' do
    let!(:role) { create(:role, name: 'User') }

    it 'creates the user if the info returned is valid' do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

      expect do
        get :create_user, params: { provider: 'openid_connect' }
      end.to change(User, :count).by(1)
    end

    it 'logs the user in and redirects to their rooms page' do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

      get :create_user, params: { provider: 'openid_connect' }

      expect(session[:user_id]).to eq(User.find_by(email: OmniAuth.config.mock_auth[:openid_connect][:info][:email]).id)
      expect(response).to redirect_to('/rooms')
    end

    it 'assigns the User role to the user' do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]

      get :create_user, params: { provider: 'openid_connect' }

      expect(User.find_by(email: OmniAuth.config.mock_auth[:openid_connect][:info][:email]).role).to eq(role)
    end
  end
end
