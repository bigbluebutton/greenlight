# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  before do
    request.headers['ACCEPT'] = 'application/json'
  end

  describe 'DELETE users#destroy' do
    it 'deletes the user' do
      user = create(:user)
      delete :destroy, params: { id: user.id }
      expect(response).to have_http_status(:ok)
    end

    it 'returns an error if the user id is invalid' do
      delete :destroy, params: { id: nil }
      expect(response).to have_http_status(:bad_request)
    end
  end
end
