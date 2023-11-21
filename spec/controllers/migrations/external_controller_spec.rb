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
          encrypted_params = encrypt_params({ role: { name: '', provider: 'greenlight', role_permissions: {} } }, expires_in: 10.seconds)
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

      describe 'when role already exists and role permissions are not default values' do
        let!(:role) { create(:role) }
        let!(:not_greenlight_role) { create(:role, provider: 'not_greenlight') }
        let!(:create_room_role_permission) { create(:role_permission, role:, permission: create(:permission, name: 'ManageUsers'), value: 'true') }
        let!(:not_greenlight_create_room_role_permission) do
          create(:role_permission,
                 role: not_greenlight_role,
                 permission: create(:permission, name: 'ManageUsers'),
                 value: 'true')
        end

        it 'creates role role_permissions with the given value' do
          role_permissions = {
            ManageUsers: 'false'
          }

          encrypted_params = encrypt_params({ role: { name: role.name, provider: role.provider, role_permissions: } }, expires_in: 10.seconds)
          post :create_role, params: { v2: { encrypted_params: } }
          expect(create_room_role_permission.reload.value).to eq(role_permissions[:ManageUsers])
          expect(response).to have_http_status(:created)
        end

        it 'does not create other providers role role_permissions' do
          role_permissions = {
            ManageUsers: 'false'
          }

          encrypted_params = encrypt_params({ role: { name: role.name, provider: role.provider, role_permissions: } }, expires_in: 10.seconds)
          post :create_role, params: { v2: { encrypted_params: } }
          expect(not_greenlight_create_room_role_permission.reload.value).not_to eq(role_permissions[:ManageUsers])
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
          key = Rails.application.secret_key_base[1..32]

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
        password_digest: 'fake_password_digest',
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
            expect(user.password_digest).to eq(valid_user_params[:password_digest])
            expect(response).to have_http_status(:created)
          end

          it 'creates the user without a password if provider is not greenlight' do
            tenant = create(:tenant)
            role = create(:role, name: valid_user_role.name, provider: tenant.name)
            valid_user_params[:provider] = tenant.name

            encrypted_params = encrypt_params({ user: valid_user_params }, expires_in: 10.seconds)

            expect_any_instance_of(described_class).to receive(:generate_secure_pwd).and_call_original
            expect { post :create_user, params: { v2: { encrypted_params: } } }.to change(User, :count).from(0).to(1)
            expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued

            user = User.take
            expect(user.name).to eq(valid_user_params[:name])
            expect(user.email).to eq(valid_user_params[:email])
            expect(user.language).to eq(valid_user_params[:language])
            expect(user.role).to eq(role)
            expect(user.session_token).to be_present
            expect(user.provider).to eq(tenant.name)
            expect(response).to have_http_status(:created)
            expect(user.password_digest).not_to be_present
          end
        end

        context 'when the provider does not exists' do
          before { valid_user_params[:provider] = 'not_a_provider' }

          it 'returns :bad_request without creating a user' do
            encrypted_params = encrypt_params({ user: valid_user_params }, expires_in: 10.seconds)
            expect { post :create_user, params: { v2: { encrypted_params: } } }.not_to change(User, :count)
            expect(response).to have_http_status(:bad_request)
          end
        end

        context 'when the provider is ldap' do
          before { valid_user_params[:provider] = 'ldap' }

          it 'creates a user with the greenlight provider' do
            encrypted_params = encrypt_params({ user: valid_user_params }, expires_in: 10.seconds)
            expect { post :create_user, params: { v2: { encrypted_params: } } }.to change(User, :count).from(0).to(1)
            user = User.take
            expect(user.provider).to eq('greenlight')
            expect(response).to have_http_status(:created)
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
            expect(user.password_digest).to eq(valid_user_params[:password_digest])
            expect(response).to have_http_status(:created)
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

        context 'when providing a valid :password_digest' do
          before do
            temp_user = create(:user, password: 'Password1!')
            valid_user_params.merge!(password_digest: temp_user.password_digest)
          end

          it 'returns :created and creates a user while ignoring the extra values' do
            encrypted_params = encrypt_params({ user: valid_user_params }, expires_in: 10.seconds)
            expect { post :create_user, params: { v2: { encrypted_params: } } }.to change(User, :count).by(1)

            user = User.take
            expect(user.name).to eq(valid_user_params[:name])
            expect(user.email).to eq(valid_user_params[:email])
            expect(user.language).to eq(valid_user_params[:language])
            expect(user.role).to eq(valid_user_role)
            expect(user.session_token).to be_present
            expect(user.provider).to eq(valid_user_params[:provider])
            expect(response).to have_http_status(:created)
            expect(user.authenticate('Password1!')).to be_truthy
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
          key = Rails.application.secret_key_base[1..32]

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
          key = Rails.application.secret_key_base[1..32]
          encrypted_params = encrypt_params({ room: valid_room_params }, key:, expires_in: 10.seconds)
          expect { post :create_room, params: { v2: { encrypted_params: } } }.not_to change(Room, :count)
          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end

  describe '#create_settings' do
    let(:primary_color_setting) { create(:setting, name: 'PrimaryColor') }
    let(:terms_setting) { create(:setting, name: 'Terms') }
    let(:registration_method_setting) { create(:setting, name: 'RegistrationMethod') }

    let!(:site_setting_a) { create(:site_setting, setting: primary_color_setting, value: 'valueA') }
    let!(:site_setting_b) { create(:site_setting, setting: terms_setting, value: 'valueB') }
    let!(:site_setting_c) { create(:site_setting, setting: registration_method_setting, value: 'valueC') }

    let!(:site_setting_d) do
      create(:site_setting, setting: primary_color_setting, value: 'valueA', provider: 'not_greenlight')
    end
    let!(:site_setting_e) do
      create(:site_setting, setting: terms_setting, value: 'valueB', provider: 'not_greenlight')
    end
    let!(:site_setting_f) do
      create(:site_setting, setting: registration_method_setting, value: 'valueC', provider: 'not_greenlight')
    end

    let(:record_meeting_option) { create(:meeting_option, name: 'record') }
    let(:mute_on_start_meeting_option) { create(:meeting_option, name: 'muteOnStart') }
    let(:guest_policy_meeting_option) { create(:meeting_option, name: 'guestPolicy') }

    let!(:rooms_config_a) { create(:rooms_configuration, meeting_option: record_meeting_option, value: 'true') }
    let!(:rooms_config_b) { create(:rooms_configuration, meeting_option: mute_on_start_meeting_option, value: 'true') }
    let!(:rooms_config_c) { create(:rooms_configuration, meeting_option: guest_policy_meeting_option, value: 'true') }

    let!(:rooms_config_d) do
      create(:rooms_configuration, meeting_option: record_meeting_option, value: 'true', provider: 'not_greenlight')
    end
    let!(:rooms_config_e) do
      create(:rooms_configuration, meeting_option: mute_on_start_meeting_option, value: 'true', provider: 'not_greenlight')
    end
    let!(:rooms_config_f) do
      create(:rooms_configuration, meeting_option: guest_policy_meeting_option, value: 'true', provider: 'not_greenlight')
    end

    let(:valid_settings_params) do
      {
        provider: 'greenlight',
        site_settings: {
          PrimaryColor: 'new_valueA',
          Terms: 'new_valueB',
          RegistrationMethod: 'new_valueC'
        },
        rooms_configurations: {
          record: 'false',
          muteOnStart: 'false',
          guestPolicy: 'false'
        }
      }
    end

    before { clear_enqueued_jobs }

    it 'updates the site settings' do
      encrypted_params = encrypt_params({ settings: valid_settings_params }, expires_in: 10.seconds)
      post :create_settings, params: { v2: { encrypted_params: } }
      expect(site_setting_a.reload.value).to eq(valid_settings_params[:site_settings][:PrimaryColor])
      expect(site_setting_b.reload.value).to eq(valid_settings_params[:site_settings][:Terms])
      expect(site_setting_c.reload.value).to eq(valid_settings_params[:site_settings][:RegistrationMethod])
    end

    it 'does not update the site settings for other providers' do
      encrypted_params = encrypt_params({ settings: valid_settings_params }, expires_in: 10.seconds)
      post :create_settings, params: { v2: { encrypted_params: } }
      expect(site_setting_d.reload.value).to eq('valueA')
      expect(site_setting_e.reload.value).to eq('valueB')
      expect(site_setting_f.reload.value).to eq('valueC')
    end

    it 'updates the room configs' do
      encrypted_params = encrypt_params({ settings: valid_settings_params }, expires_in: 10.seconds)
      post :create_settings, params: { v2: { encrypted_params: } }
      expect(rooms_config_a.reload.value).to eq(valid_settings_params[:rooms_configurations][:record])
      expect(rooms_config_b.reload.value).to eq(valid_settings_params[:rooms_configurations][:muteOnStart])
      expect(rooms_config_c.reload.value).to eq(valid_settings_params[:rooms_configurations][:guestPolicy])
    end

    it 'does not update the room configs for other providers' do
      encrypted_params = encrypt_params({ settings: valid_settings_params }, expires_in: 10.seconds)
      post :create_settings, params: { v2: { encrypted_params: } }
      expect(rooms_config_d.reload.value).to eq('true')
      expect(rooms_config_e.reload.value).to eq('true')
      expect(rooms_config_f.reload.value).to eq('true')
    end
  end

  private

  def encrypt_params(params, key: nil, expires_at: nil, expires_in: nil, purpose: nil)
    key = Rails.application.secret_key_base[0..31] if key.nil?
    crypt = ActiveSupport::MessageEncryptor.new(key, cipher: 'aes-256-gcm', serializer: Marshal)
    crypt.encrypt_and_sign(params, expires_at:, expires_in:, purpose:)
  end
end
