# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Migrations::ExternalController, type: :controller do
  before do
    request.headers['ACCEPT'] = 'application/json'
    freeze_time
  end

  describe '#create_role' do
    context 'when decryption passes' do
      describe 'when decrypted params encapsulation is conform and data is valid' do
        it 'returns :created and creates a role' do
          encrypted_params = encrypt_params({ role: { name: 'CrazyRole' } }, expires_in: 10.seconds)
          expect { post :create_role, params: { v2: { encrypted_params: } } }.to change(Role, :count).from(0).to(1)
          role = Role.take
          expect(role.name).to eq('CrazyRole')
          expect(role.provider).to eq('greenlight')
          expect(response).to have_http_status(:created)
        end
      end

      describe 'when decrypted params data are invalid' do
        it 'returns :bad_request without creating a role' do
          encrypted_params = encrypt_params({ role: { name: '' } }, expires_in: 10.seconds)
          expect { post :create_role, params: { v2: { encrypted_params: } } }.not_to change(Role, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end

      describe 'when decrypted params encapsulation is not conform' do
        it 'returns :bad_request without creating a role' do
          encrypted_params = encrypt_params({ not_role: { name: 'CrazyRole' } }, expires_in: 10.seconds)
          expect { post :create_role, params: { v2: { encrypted_params: } } }.not_to change(Role, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end
    end

    context 'when decryption failes' do
      describe 'because payload encapsulation is not conform' do
        it 'returns :bad_request without creating a role' do
          encrypted_params = encrypt_params({ role: { name: 'CrazyRole' } }, expires_in: 10.seconds)
          expect { post :create_role, params: { not_v2: { encrypted_params: } } }.not_to change(Role, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end

      describe 'because the encrypted_params cipher isn\'t a String' do
        it 'returns :bad_request without creating a role' do
          expect { post :create_role, params: { v2: { encrypted_params: { something: 'else' } } } }.not_to change(Role, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end

      describe 'because the decrypted params isn\'t a Hash' do
        it 'returns :bad_request without creating a role' do
          encrypted_params = encrypt_params('I am  a Hash!!', expires_in: 10.seconds)
          expect { post :create_role, params: { v2: { encrypted_params: } } }.not_to change(Role, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end

      describe 'because the encrypted payload expired' do
        it 'returns :bad_request without creating a role' do
          encrypted_params = encrypt_params({ role: { name: 'CrazyRole' } }, expires_in: 10.seconds)
          travel_to 11.seconds.from_now
          expect { post :create_role, params: { v2: { encrypted_params: } } }.not_to change(Role, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end

      describe 'because the ciphertext was not generated with the same configuration' do
        it 'returns :bad_request without creating a role' do
          key = Rails.application.secrets.secret_key_base[1..32]

          encrypted_params = encrypt_params({ role: { name: 'CrazyRole' } }, key:, expires_in: 10.seconds)
          expect { post :create_role, params: { v2: { encrypted_params: } } }.not_to change(Role, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end

  private

  def encrypt_params(params, key: nil, expires_at: nil, expires_in: nil, purpose: nil)
    key = Rails.application.secrets.secret_key_base[0..31] if key.nil?
    crypt = ActiveSupport::MessageEncryptor.new(key, cipher: 'aes-256-gcm', serializer: Marshal)
    crypt.encrypt_and_sign(params, expires_at:, expires_in:, purpose:)
  end
end
