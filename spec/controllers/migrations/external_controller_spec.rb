# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
          encrypted_params = encrypt_params({ role: { name: 'CrazyRole', provider: 'greenlight', role_permissions: {} } }, expires_in: 10.seconds)
          expect { post :create_role, params: { v2: { encrypted_params: } } }.to change(Role, :count).from(0).to(1)
          role = Role.take
          expect(role.name).to eq('CrazyRole')
          expect(role.provider).to eq('greenlight')
          expect(response).to have_http_status(:created)
        end
      end

      describe 'when decrypted params data are invalid' do
        it 'returns :bad_request without creating a role' do
          encrypted_params = encrypt_params({ role: { name: '', role_permissions: {} } }, expires_in: 10.seconds)
          expect { post :create_role, params: { v2: { encrypted_params: } } }.not_to change(Role, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end

      describe 'when decrypted params encapsulation is not conform' do
        it 'returns :bad_request without creating a role' do
          encrypted_params = encrypt_params({ not_role: { name: 'CrazyRole', role_permissions: {} } }, expires_in: 10.seconds)
          expect { post :create_role, params: { v2: { encrypted_params: } } }.not_to change(Role, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end

      describe 'when role was created' do
        let(:role) { create(:role, provider: 'greenlight', name: 'OnlyOne') }

        it 'returns :created without creating a role' do
          encrypted_params = encrypt_params({ role: { name: role.name, provider: 'greenlight', role_permissions: {} } }, expires_in: 10.seconds)
          expect { post :create_role, params: { v2: { encrypted_params: } } }.not_to change(Role, :count)
          expect(response).to have_http_status(:created)
        end
      end
    end

    context 'when decryption failes' do
      describe 'because payload encapsulation is not conform' do
        it 'returns :bad_request without creating a role' do
          encrypted_params = encrypt_params({ role: { name: 'CrazyRole', role_permissions: {} } }, expires_in: 10.seconds)
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
          encrypted_params = encrypt_params({ role: { name: 'CrazyRole', role_permissions: {} } }, expires_in: 10.seconds)
          travel_to 11.seconds.from_now
          expect { post :create_role, params: { v2: { encrypted_params: } } }.not_to change(Role, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end

      describe 'because the ciphertext was not generated with the same configuration' do
        it 'returns :bad_request without creating a role' do
          key = Rails.application.secrets.secret_key_base[1..32]

          encrypted_params = encrypt_params({ role: { name: 'CrazyRole', role_permissions: {} } }, key:, expires_in: 10.seconds)
          expect { post :create_role, params: { v2: { encrypted_params: } } }.not_to change(Role, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end

  describe '#create_user' do
    let(:valid_user_role) { create(:role, provider: 'greenlight') }
    let(:valid_user_params) do
      {
        name: 'user',
        email: 'user@users.com',
        provider: 'greenlight',
        language: 'language',
        role: valid_user_role.name
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
          it 'returns :created, creates a user' do
            encrypted_params = encrypt_params({ user: valid_user_params }, expires_in: 10.seconds)

            expect_any_instance_of(described_class).to receive(:generate_secure_pwd).and_call_original
            expect { post :create_user, params: { v2: { encrypted_params: } } }.to change(User, :count).from(0).to(1)
            expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued

            user = User.take
            expect(user.name).to eq(valid_user_params[:name])
            expect(user.email).to eq(valid_user_params[:email])
            expect(user.language).to eq(valid_user_params[:language])
            expect(user.role).to eq(valid_user_role)
            expect(user.session_token).to be_present
            expect(user.provider).to eq('greenlight')
            expect(response).to have_http_status(:created)
            expect(user.password_digest).to be_present
          end
        end

        context 'when external_id is present' do
          before { valid_user_params[:external_id] = 'EXTERNAL' }

          it 'returns :created, creates a user but does not generate a pwd' do
            encrypted_params = encrypt_params({ user: valid_user_params }, expires_in: 10.seconds)

            expect_any_instance_of(described_class).not_to receive(:generate_secure_pwd).and_call_original
            expect { post :create_user, params: { v2: { encrypted_params: } } }.to change(User, :count).from(0).to(1)
            expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued

            user = User.take
            expect(user.name).to eq(valid_user_params[:name])
            expect(user.email).to eq(valid_user_params[:email])
            expect(user.language).to eq(valid_user_params[:language])
            expect(user.role).to eq(valid_user_role)
            expect(user.session_token).to be_present
            expect(user.provider).to eq('greenlight')
            expect(response).to have_http_status(:created)
            expect(user.password_digest).to be_blank
          end
        end

        context 'default language' do
          describe 'when language is empty' do
            before { valid_user_params[:language] = nil }

            it 'returns :created, creates a user with the default locale' do
              encrypted_params = encrypt_params({ user: valid_user_params }, expires_in: 10.seconds)
              expect { post :create_user, params: { v2: { encrypted_params: } } }.to change(User, :count).from(0).to(1)
              expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued

              user = User.take
              expect(user.name).to eq(valid_user_params[:name])
              expect(user.email).to eq(valid_user_params[:email])
              expect(user.language).to eq(I18n.default_locale.to_s)
              expect(user.role).to eq(valid_user_role)
              expect(user.session_token).to be_present
              expect(user.provider).to eq('greenlight')
              expect(response).to have_http_status(:created)
            end
          end

          describe 'when language is "default"' do
            before { valid_user_params[:language] = 'default' }

            it 'returns :created, creates a user with the default locale' do
              encrypted_params = encrypt_params({ user: valid_user_params }, expires_in: 10.seconds)
              expect { post :create_user, params: { v2: { encrypted_params: } } }.to change(User, :count).from(0).to(1)
              expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued

              user = User.take
              expect(user.name).to eq(valid_user_params[:name])
              expect(user.email).to eq(valid_user_params[:email])
              expect(user.language).to eq(I18n.default_locale.to_s)
              expect(user.role).to eq(valid_user_role)
              expect(user.session_token).to be_present
              expect(user.provider).to eq('greenlight')
              expect(response).to have_http_status(:created)
            end
          end
        end

        context 'when providing a :provider or a :password' do
          before { valid_user_params.merge!(password: 'Password1!') }

          it 'returns :created and creates a user while ignoring the extra values' do
            encrypted_params = encrypt_params({ user: valid_user_params }, expires_in: 10.seconds)
            expect { post :create_user, params: { v2: { encrypted_params: } } }.to change(User, :count).from(0).to(1)

            user = User.take
            expect(user.name).to eq(valid_user_params[:name])
            expect(user.email).to eq(valid_user_params[:email])
            expect(user.language).to eq(valid_user_params[:language])
            expect(user.role).to eq(valid_user_role)
            expect(user.session_token).to be_present
            expect(user.provider).to eq(valid_user_params[:provider])
            expect(response).to have_http_status(:created)
            expect(user.authenticate('Password1!')).to be_falsy
          end
        end

        it 'sets user to verified' do
          encrypted_params = encrypt_params({ user: valid_user_params }, expires_in: 10.seconds)

          expect_any_instance_of(described_class).to receive(:generate_secure_pwd).and_call_original
          expect { post :create_user, params: { v2: { encrypted_params: } } }.to change(User, :count).from(0).to(1)
          expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued

          user = User.take
          expect(user.verified?).to be true
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

      describe 'when user was created' do
        let!(:user) { create(:user, valid_user_params.merge(role: valid_user_role)) }

        it 'returns :created without creating a user' do
          encrypted_params = encrypt_params({ user: valid_user_params }, expires_in: 10.seconds)

          expect_any_instance_of(described_class).not_to receive(:generate_secure_pwd).and_call_original
          expect { post :create_user, params: { v2: { encrypted_params: } } }.not_to change(User, :count)
          expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued

          expect(response).to have_http_status(:created)
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

  describe '#create_room' do
    let(:user) { create(:user) }
    let(:valid_room_params) do
      {
        name: "#{user.name}'s Room",
        friendly_id: 'us2-xy5-lf5-zl2',
        meeting_id: 'kzukaw3xk7ql5kefbfpsruud61pztf00jzltgafs',
        last_session: Time.zone.now.to_datetime,
        owner_email: user.email,
        provider: 'greenlight',
        room_settings: {},
        shared_users_emails: []
      }
    end

    before { clear_enqueued_jobs }

    context 'when decryption passes' do
      describe 'when decrypted params encapsulation is conform and data is valid' do
        it 'creates a new room' do
          encrypted_params = encrypt_params({ room: valid_room_params }, expires_in: 10.seconds)
          expect { post :create_room, params: { v2: { encrypted_params: } } }.to change(Room, :count).from(0).to(1)
          room = Room.first
          expect(room.name).to eq(valid_room_params[:name])
          expect(room.friendly_id).to eq(valid_room_params[:friendly_id])
          expect(room.meeting_id).to eq(valid_room_params[:meeting_id])
          expect(room.last_session).to eq(valid_room_params[:last_session])
          expect(room.user.provider).to eq(valid_room_params[:provider])
          expect(room.user).to eq(user)
          expect(response).to have_http_status(:created)
        end

        it 'does not create a new room if the room owner is not found' do
          valid_room_params[:owner_email] = 'random_email@google.com'
          valid_room_params[:provider] = 'random_provider'
          encrypted_params = encrypt_params({ room: valid_room_params }, expires_in: 10.seconds)
          expect { post :create_room, params: { v2: { encrypted_params: } } }.not_to change(Room, :count)
        end

        it 'does not create a new room if the room owner does not have same provider has the room data' do
          valid_room_params[:provider] = 'random_provider'
          encrypted_params = encrypt_params({ room: valid_room_params }, expires_in: 10.seconds)
          expect { post :create_room, params: { v2: { encrypted_params: } } }.not_to change(Room, :count)
        end
      end

      describe 'when decrypted params data are invalid' do
        it 'returns :bad_request without creating a room if meeting id is blank' do
          valid_room_params[:meeting_id] = ''
          encrypted_params = encrypt_params({ room: valid_room_params }, expires_in: 10.seconds)
          expect { post :create_room, params: { v2: { encrypted_params: } } }.not_to change(Room, :count)
          expect(response).to have_http_status(:bad_request)
        end

        it 'returns :bad_request without creating a room if friendly id is blank' do
          valid_room_params[:friendly_id] = ''
          encrypted_params = encrypt_params({ room: valid_room_params }, expires_in: 10.seconds)
          expect { post :create_room, params: { v2: { encrypted_params: } } }.not_to change(Room, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end

      describe 'when decrypted params encapsulation is not conform' do
        it 'returns :bad_request without creating a room' do
          encrypted_params = encrypt_params({ not_room: valid_room_params }, expires_in: 10.seconds)
          expect { post :create_room, params: { v2: { encrypted_params: } } }.not_to change(Room, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end
    end

    context 'when decryption fails' do
      describe 'because payload encapsulation is not conform' do
        it 'returns :bad_request without creating a room' do
          encrypted_params = encrypt_params({ room: valid_room_params }, expires_in: 10.seconds)
          expect { post :create_room, params: { not_v2: { encrypted_params: } } }.not_to change(Room, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end

      describe 'because the encrypted_params cipher isn\'t a String' do
        it 'returns :bad_request without creating a room' do
          expect { post :create_room, params: { v2: { encrypted_params: { something: 'unexpected' } } } }.not_to change(Room, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end

      describe 'because the decrypted params isn\'t a Hash' do
        it 'returns :bad_request without creating a room' do
          encrypted_params = encrypt_params('Not a hash', expires_in: 10.seconds)
          expect { post :create_room, params: { v2: { encrypted_params: } } }.not_to change(Room, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end

      describe 'because the encrypted payload expired' do
        it 'returns :bad_request without creating a room' do
          encrypted_params = encrypt_params({ room: valid_room_params }, expires_in: 10.seconds)
          travel_to 15.seconds.from_now
          expect { post :create_room, params: { v2: { encrypted_params: } } }.not_to change(Room, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end

      describe 'because the ciphertext was not generated with the same configuration' do
        it 'returns :bad_request without creating a room' do
          key = Rails.application.secrets.secret_key_base[1..32]
          encrypted_params = encrypt_params({ room: valid_room_params }, key:, expires_in: 10.seconds)
          expect { post :create_room, params: { v2: { encrypted_params: } } }.not_to change(Room, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end

  describe '#create_settings' do
    let!(:site_setting_a) { create(:site_setting, setting: create(:setting, name: 'settingA'), value: 'valueA') }
    let!(:site_setting_b) { create(:site_setting, setting: create(:setting, name: 'settingB'), value: 'valueB') }
    let!(:site_setting_c) { create(:site_setting, setting: create(:setting, name: 'settingC'), value: 'valueC') }

    let!(:rooms_config_a) { create(:rooms_configuration, meeting_option: create(:meeting_option, name: 'optionA'), default_value: 'valueA') }
    let!(:rooms_config_b) { create(:rooms_configuration, meeting_option: create(:meeting_option, name: 'optionB'), default_value: 'valueB') }
    let!(:rooms_config_c) { create(:rooms_configuration, meeting_option: create(:meeting_option, name: 'optionC'), default_value: 'valueC') }

    let(:valid_settings_params) do
      {
        provider: 'greenlight',
        site_settings: {
          settingA: 'new_valueA',
          settingB: 'new_valueB',
          settingC: 'new_valueC'
        },
        room_configurations: {
          optionA: 'new_valueA',
          optionB: 'new_valueB',
          optionC: 'new_valueC'
        }
      }
    end

    before { clear_enqueued_jobs }

    it 'creates a new setting' do
      encrypted_params = encrypt_params({ room: valid_settings_params }, expires_in: 10.seconds)
      post :create_settings, params: { v2: { encrypted_params: } }
      expect(site_setting_a.value).to eq(valid_settings_params[:site_settings][:settingA])
      expect(site_setting_b.value).to eq(valid_settings_params[:site_settings][:settingB])
      expect(site_setting_c.value).to eq(valid_settings_params[:site_settings][:settingC])
    end

    it 'creates a new room configs' do
      encrypted_params = encrypt_params({ room: valid_settings_params }, expires_in: 10.seconds)
      post :create_settings, params: { v2: { encrypted_params: } }
      expect(rooms_config_a.value).to eq(valid_settings_params[:room_configurations][:optionA])
      expect(rooms_config_b.value).to eq(valid_settings_params[:room_configurations][:optionB])
      expect(rooms_config_c.value).to eq(valid_settings_params[:room_configurations][:optionC])
    end
  end

  private

  def encrypt_params(params, key: nil, expires_at: nil, expires_in: nil, purpose: nil)
    key = Rails.application.secrets.secret_key_base[0..31] if key.nil?
    crypt = ActiveSupport::MessageEncryptor.new(key, cipher: 'aes-256-gcm', serializer: Marshal)
    crypt.encrypt_and_sign(params, expires_at:, expires_in:, purpose:)
  end
end
