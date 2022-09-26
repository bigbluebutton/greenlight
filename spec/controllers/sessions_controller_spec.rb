# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :controller do
  let(:user) { create(:user) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user.id
  end

  describe '#create' do
    it 'creates a regular session if the remember me checkbox is not selected' do
      user = create(:user, email: 'email@email.com', password: 'Password1!')

      post :create, params: {
        session: {
          email: 'email@email.com',
          password: 'Password1!',
          extend_session: false
        }
      }, as: :json

      expect(cookies.encrypted[:_extended_session]).to be_nil
      expect(session[:user_id]).to eq(user.id)
    end

    it 'creates an extended session if the remember me checkbox is selected' do
      user = create(:user, email: 'email@email.com', password: 'Password1!')
      post :create, params: {
        session: {
          email: 'email@email.com',
          password: 'Password1!',
          extend_session: true
        }
      }, as: :json

      expect(cookies.encrypted[:_extended_session]['user_id']).to eq(user.id)
      expect(session[:user_id]).to eq(user.id)
    end
  end

  describe '#destroy' do
    it 'signs off the user' do
      user = create(:user)
      session[:user_id] = user.id

      delete :destroy

      expect(cookies.encrypted[:_extended_session]).to be_nil
      expect(session[:user_id]).to be_nil
    end
  end
end
