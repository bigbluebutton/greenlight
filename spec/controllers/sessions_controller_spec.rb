# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :controller do
  let!(:user) { create(:user, email: 'email@email.com', password: 'Password1!', password_confirmation: 'Password1!') }

  before do
    request.headers['ACCEPT'] = 'application/json'
  end

  describe '#create' do
    it 'creates a regular session if the remember me checkbox is not selected' do
      post :create, params: {
        session: {
          email: 'email@email.com',
          password: 'Password1!',
          extend_session: false
        }
      }, as: :json

      expect(cookies.encrypted[:_extended_session]).to be_nil
      expect(session[:session_token]).to eq(user.reload.session_token)
    end

    it 'creates an extended session if the remember me checkbox is selected' do
      post :create, params: {
        session: {
          email: 'email@email.com',
          password: 'Password1!',
          extend_session: true
        }
      }, as: :json

      expect(cookies.encrypted[:_extended_session]['session_token']).to eq(user.reload.session_token)
      expect(session[:session_token]).to eq(user.session_token)
    end

    it 'returns UnverifiedUser error if the user is not verified' do
      unverified_user = create(:user, password: 'Password1!', verified: false)

      post :create, params: {
        session: {
          email: unverified_user.email,
          password: 'Password1!'
        }
      }

      expect(JSON.parse(response.body)['data']).to eq(unverified_user.id)
      expect(JSON.parse(response.body)['errors']).to eq('UnverifiedUser')
    end

    it 'returns BannedUser error if the user is banned' do
      banned_user = create(:user, password: 'Password1!', status: :banned)

      post :create, params: {
        session: {
          email: banned_user.email,
          password: 'Password1!'
        }
      }

      expect(JSON.parse(response.body)['errors']).to eq('BannedUser')
    end

    it 'returns Pending error if the user is banned' do
      banned_user = create(:user, password: 'Password1!', status: :pending)

      post :create, params: {
        session: {
          email: banned_user.email,
          password: 'Password1!'
        }
      }

      expect(JSON.parse(response.body)['errors']).to eq('PendingUser')
    end
  end

  describe '#destroy' do
    it 'signs off the user' do
      sign_in_user(user)

      delete :destroy

      expect(cookies.encrypted[:_extended_session]).to be_nil
      expect(session[:session_token]).to be_nil
    end
  end
end
