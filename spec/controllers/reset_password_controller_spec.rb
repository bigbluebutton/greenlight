# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ResetPasswordController, type: :controller do
  before do
    request.headers['ACCEPT'] = 'application/json'
  end

  describe 'POST reset_password#create' do
    before { create(:user, email: 'test@greenlight.com') }

    it 'generates a unique token and saves its digest for valid emails' do
      token = 'ZekpWTPGFsuaP1WngE6LVCc69Zs7YSKoOJFLkfKu'
      allow_any_instance_of(User).to receive(:generate_unique_token).and_return(token)

      post :create, params: { user: { email: 'test@greenlight.com' } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']).to eq({ 'token' => token })
    end

    it 'returns :bad_request for invalid params' do
      post :create, params: { not_user: { not_email: 'invalid@greenlight.com' } }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns :ok when the digest cannot be saved' do
      allow_any_instance_of(User).to receive(:generate_unique_token).and_return(false)

      post :create, params: { user: { email: 'test@greenlight.com' } }
      expect(response).to have_http_status(:ok)
    end

    it 'returns :ok for invalid emails' do
      post :create, params: { user: { email: 'not_a_tester@greenlight.com' } }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST reset_password#reset' do
    let(:valid_params) do
      { new_password: 'Glv3IsAwesome!', token: 'ZekpWTPGFsuaP1WngE6LVCc69Zs7YSKoOJFLkfKu' }
    end

    it 'updates the found user by digest for valid params' do
      user = create(:user, password: 'Test12345678+')
      allow(User).to receive(:verify_token).with(valid_params[:token]).and_return(user)
      expect(User).to receive(:verify_token).with(valid_params[:token])

      post :reset, params: { user: valid_params }
      expect(response).to have_http_status(:ok)
      expect(user.reload.authenticate(valid_params[:new_password])).to be_truthy
    end

    it 'returns :forbidden for invalid token' do
      allow(User).to receive(:verify_token).and_return(false)
      expect(User).to receive(:verify_token).with(valid_params[:token])

      post :reset, params: { user: valid_params }
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns :bad_request for missing params' do
      invalid_params = { new_password: '', token: '' }

      post :reset, params: { user: invalid_params }
      expect(response).to have_http_status(:bad_request)
    end
  end
end
