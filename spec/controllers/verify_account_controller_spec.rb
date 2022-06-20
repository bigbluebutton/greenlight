# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::VerifyAccountController, type: :controller do
  before do
    request.headers['ACCEPT'] = 'application/json'
  end

  describe 'POST verify_account#create' do
    before { create(:user, email: 'inactive@greenlight.com') }

    it 'generates a unique token and saves its digest for valid emails' do
      token = 'ZekpWTPGFsuaP1WngE6LVCc69Zs7YSKoOJFLkfKu'
      allow_any_instance_of(User).to receive(:generate_activation_token!).and_return(token)

      post :create, params: { user: { email: 'inactive@greenlight.com' } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']).to eq({ 'token' => token })
    end

    it 'returns :bad_request for invalid params' do
      post :create, params: { not_user: { not_email: 'inactive@greenlight.com' } }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns :ok for active users' do
      create(:user, email: 'active@users.com', active: true)
      post :create, params: { user: { email: 'active@users.com' } }

      expect(response).to have_http_status(:ok)
    end

    it 'returns :ok for invalid emails' do
      post :create, params: { user: { email: 'invalid@greenlight.com' } }
      expect(response).to have_http_status(:ok)
    end
  end
end
