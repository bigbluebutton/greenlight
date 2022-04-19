# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  before do
    request.headers['ACCEPT'] = 'application/json'
  end

  describe 'POST users#update' do
    it 'updates the users attributes' do
      updated_params = {
        name: 'New Name',
        email: 'newemail@gmail.com'
      }
      user = create(:user)
      patch :update, params: { id: user.id, user: updated_params }
      user.reload
      expect(response).to have_http_status(:ok)
      expect(user.name).to eq(updated_params[:name])
      expect(user.email).to eq(updated_params[:email])
    end

    it 'returns an error if the user update fails' do
      user = create(:user)
      patch :update, params: { id: user.id, user: { name: nil } }
      expect(response).to have_http_status(:bad_request)
      expect(user.reload.name).to eq(user.name)
    end
  end
end
