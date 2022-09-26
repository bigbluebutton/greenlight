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
