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

  describe '#create_user' do
    let(:valid_user_params) do
      role = create(:role, provider: 'greenlight')
      {
        name: 'user',
        email: 'user@users.com',
        language: 'language',
        role: role.name
      }
    end

    before { clear_enqueued_jobs }

    describe '#generate_secure_pwd' do
      before { allow_any_instance_of(described_class).to receive(:generate_secure_pwd).and_call_original }

      it 'generates a secure random complex password' do
        pwd_pattern = %r{\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[`@%~!#£$\\^&*()\]\[+={}/|:;"'<>\-,.?_ ]).{8,}\z}
        random_pwd = described_class.new.generate_secure_pwd
        expect(random_pwd).to match(pwd_pattern)
        expect(random_pwd.size).to eq(26)
      end
    end

    context 'when decryption passes' do
      describe 'when decrypted params encapsulation is conform and data is valid' do
        context 'when external_id isn\'t present' do
          it 'returns :created, creates a user and sends a reset email' do
            encrypted_params = encrypt_params({ user: valid_user_params }, expires_in: 10.seconds)

            expect_any_instance_of(described_class).to receive(:generate_secure_pwd).and_call_original
            expect { post :create_user, params: { v2: { encrypted_params: } } }.to change(User, :count).from(0).to(1)
            expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.at(:no_wait).exactly(:once).with('UserMailer', 'reset_password_email',
                                                                                                         'deliver_now', Hash)
            user = User.take
            expect(user.name).to eq(valid_user_params[:name])
            expect(user.email).to eq(valid_user_params[:email])
            expect(user.language).to eq(valid_user_params[:language])
            expect(user.role.name).to eq(valid_user_params[:role])
            expect(user.session_token).to be_present
            expect(user.provider).to eq('greenlight')
            expect(response).to have_http_status(:created)
            expect(user.password_digest).to be_present
            expect(user.reset_digest).to be_present
          end
        end

        context 'when external_id is present' do
          before { valid_user_params[:external_id] = 'EXTERNAL' }

          it 'returns :created, creates a user but does not send a reset email' do
            encrypted_params = encrypt_params({ user: valid_user_params }, expires_in: 10.seconds)

            expect_any_instance_of(described_class).to receive(:generate_secure_pwd).and_call_original
            expect { post :create_user, params: { v2: { encrypted_params: } } }.to change(User, :count).from(0).to(1)
            expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued

            user = User.take
            expect(user.name).to eq(valid_user_params[:name])
            expect(user.email).to eq(valid_user_params[:email])
            expect(user.language).to eq(valid_user_params[:language])
            expect(user.role.name).to eq(valid_user_params[:role])
            expect(user.session_token).to be_present
            expect(user.provider).to eq('greenlight')
            expect(response).to have_http_status(:created)
            expect(user.password_digest).to be_present
            expect(user.reset_digest).to be_blank
          end
        end

        context 'default language' do
          describe 'when language is empty' do
            before { valid_user_params[:language] = nil }

            it 'returns :created, creates a user with the default locale and sends a reset email' do
              encrypted_params = encrypt_params({ user: valid_user_params }, expires_in: 10.seconds)
              expect { post :create_user, params: { v2: { encrypted_params: } } }.to change(User, :count).from(0).to(1)

              user = User.take
              expect(user.name).to eq(valid_user_params[:name])
              expect(user.email).to eq(valid_user_params[:email])
              expect(user.language).to eq(I18n.default_locale.to_s)
              expect(user.role.name).to eq(valid_user_params[:role])
              expect(user.session_token).to be_present
              expect(user.provider).to eq('greenlight')
              expect(response).to have_http_status(:created)
            end
          end

          describe 'when language is "default"' do
            before { valid_user_params[:language] = 'default' }

            it 'returns :created, creates a user with the default locale and sends a reset email' do
              encrypted_params = encrypt_params({ user: valid_user_params }, expires_in: 10.seconds)
              expect { post :create_user, params: { v2: { encrypted_params: } } }.to change(User, :count).from(0).to(1)

              user = User.take
              expect(user.name).to eq(valid_user_params[:name])
              expect(user.email).to eq(valid_user_params[:email])
              expect(user.language).to eq(I18n.default_locale.to_s)
              expect(user.role.name).to eq(valid_user_params[:role])
              expect(user.session_token).to be_present
              expect(user.provider).to eq('greenlight')
              expect(response).to have_http_status(:created)
            end
          end
        end

        context 'when providing a :provider or a :password' do
          before { valid_user_params.merge!(provider: 'lightgreen', password: 'Password1!') }

          it 'returns :created and creates a user while ignoring the extra values' do
            encrypted_params = encrypt_params({ user: valid_user_params }, expires_in: 10.seconds)
            expect { post :create_user, params: { v2: { encrypted_params: } } }.to change(User, :count).from(0).to(1)

            user = User.take
            expect(user.name).to eq(valid_user_params[:name])
            expect(user.email).to eq(valid_user_params[:email])
            expect(user.language).to eq(valid_user_params[:language])
            expect(user.role.name).to eq(valid_user_params[:role])
            expect(user.session_token).to be_present
            expect(user.provider).to eq('greenlight')
            expect(response).to have_http_status(:created)
            expect(user.authenticate('Password1!')).to be_falsy
          end
        end
      end

      describe 'when decrypted params encapsulation is not conform' do
        it 'returns :bad_request without creating a user' do
          encrypted_params = encrypt_params({ not_user: { user: valid_user_params } }, expires_in: 10.seconds)
          expect_any_instance_of(described_class).not_to receive(:generate_secure_pwd)
          expect { post :create_user, params: { v2: { encrypted_params: } } }.not_to change(User, :count)
          expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
          expect(response).to have_http_status(:bad_request)
        end
      end

      describe 'when decrypted params data are invalid' do
        context 'because user data is invalid' do
          let(:invalid_user_params) { valid_user_params.merge!(name: '', email: 'invalid') }

          it 'returns :bad_request without creating a user' do
            encrypted_params = encrypt_params({ user: invalid_user_params }, expires_in: 10.seconds)
            expect { post :create_user, params: { v2: { encrypted_params: } } }.not_to change(User, :count)
            expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
            expect(response).to have_http_status(:bad_request)
          end
        end

        context 'because target role is invalid' do
          let(:invalid_user_params) { valid_user_params.merge!(role: '404') }

          describe 'when role is inexistant' do
            it 'returns :bad_request without creating a user' do
              encrypted_params = encrypt_params({ user: invalid_user_params }, expires_in: 10.seconds)
              expect_any_instance_of(described_class).not_to receive(:generate_secure_pwd)
              expect { post :create_user, params: { v2: { encrypted_params: } } }.not_to change(User, :count)
              expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
              expect(response).to have_http_status(:bad_request)
            end
          end

          describe 'when role exists' do
            context 'but on a different provider' do
              before { create(:role, name: '404', provider: 'lightgreen') }

              it 'returns :bad_request without creating a user' do
                encrypted_params = encrypt_params({ user: invalid_user_params }, expires_in: 10.seconds)
                expect_any_instance_of(described_class).not_to receive(:generate_secure_pwd)
                expect { post :create_user, params: { v2: { encrypted_params: } } }.not_to change(User, :count)
                expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
                expect(response).to have_http_status(:bad_request)
              end
            end

            context 'but :role is not a role name' do
              before do
                create(:role, name: 'CrazyRole', provider: 'greenlight')
                invalid_user_params[:role] = { name: 'CrazyRole', provider: 'greenlight' }
              end

              it 'returns :bad_request without creating a user' do
                encrypted_params = encrypt_params({ user: invalid_user_params }, expires_in: 10.seconds)
                expect_any_instance_of(described_class).not_to receive(:generate_secure_pwd)
                expect { post :create_user, params: { v2: { encrypted_params: } } }.not_to change(User, :count)
                expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
                expect(response).to have_http_status(:bad_request)
              end
            end
          end
        end
      end
    end

    context 'when decryption failes' do
      describe 'because payload encapsulation is not conform' do
        it 'returns :bad_request without creating a user' do
          encrypted_params = encrypt_params({ user: valid_user_params }, expires_in: 10.seconds)
          expect_any_instance_of(described_class).not_to receive(:generate_secure_pwd)
          expect { post :create_user, params: { not_v2: { encrypted_params: } } }.not_to change(User, :count)
          expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
          expect(response).to have_http_status(:bad_request)
        end
      end

      describe 'because the encrypted_params cipher isn\'t a String' do
        it 'returns :bad_request without creating a user' do
          expect_any_instance_of(described_class).not_to receive(:generate_secure_pwd)
          expect { post :create_user, params: { v2: { encrypted_params: { something: 'else' } } } }.not_to change(User, :count)
          expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
          expect(response).to have_http_status(:bad_request)
        end
      end

      describe 'because the decrypted params isn\'t a Hash' do
        it 'returns :bad_request without creating a user' do
          encrypted_params = encrypt_params('I am  a Hash!!', expires_in: 10.seconds)
          expect_any_instance_of(described_class).not_to receive(:generate_secure_pwd)
          expect { post :create_user, params: { v2: { encrypted_params: } } }.not_to change(User, :count)
          expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
          expect(response).to have_http_status(:bad_request)
        end
      end

      describe 'because the encrypted payload expired' do
        it 'returns :bad_request without creating a user' do
          encrypted_params = encrypt_params({ user: valid_user_params }, expires_in: 10.seconds)
          travel_to 11.seconds.from_now
          expect_any_instance_of(described_class).not_to receive(:generate_secure_pwd)
          expect { post :create_user, params: { v2: { encrypted_params: } } }.not_to change(User, :count)
          expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
          expect(response).to have_http_status(:bad_request)
        end
      end

      describe 'because the ciphertext was not generated with the same configuration' do
        it 'returns :bad_request without creating a user' do
          key = Rails.application.secrets.secret_key_base[1..32]

          encrypted_params = encrypt_params({ user: valid_user_params }, key:, expires_in: 10.seconds)
          expect_any_instance_of(described_class).not_to receive(:generate_secure_pwd)
          expect { post :create_user, params: { v2: { encrypted_params: } } }.not_to change(User, :count)
          expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
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
