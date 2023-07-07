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

RSpec.describe Api::V1::UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:user_with_manage_users_permission) { create(:user, :with_manage_users_permission) }
  let(:fake_setting_getter) { instance_double(SettingGetter) }

  before do
    ENV['SMTP_SERVER'] = 'test.com'
    allow(controller).to receive(:external_authn_enabled?).and_return(false)
    request.headers['ACCEPT'] = 'application/json'
  end

  describe '#create' do
    let(:user_params) do
      {
        user: {
          name: Faker::Name.name,
          email: Faker::Internet.email,
          password: 'Password123+',
          language: 'language'
        }
      }
    end

    before do
      create(:role, name: 'User') # Needed for admin#create
      clear_enqueued_jobs
      allow(SettingGetter).to receive(:new).and_call_original
      allow(SettingGetter).to receive(:new).with(setting_name: 'DefaultRole', provider: 'greenlight').and_return(fake_setting_getter)
      allow(fake_setting_getter).to receive(:call).and_return('User')

      reg_method = instance_double(SettingGetter) # TODO: - ahmad: Completely refactor how setting getter can be mocked
      allow(SettingGetter).to receive(:new).with(setting_name: 'RegistrationMethod', provider: 'greenlight').and_return(reg_method)
      allow(reg_method).to receive(:call).and_return(SiteSetting::REGISTRATION_METHODS[:open])
    end

    context 'valid user params' do
      it 'creates a user account for valid params' do
        expect { post :create, params: user_params }.to change(User, :count).from(0).to(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['errors']).to be_nil
      end

      it 'assigns the User role to the user' do
        post :create, params: user_params
        expect(User.find_by(email: user_params[:user][:email]).role.name).to eq('User')
      end

      context 'User language' do
        it 'Persists the user language in the user record' do
          post :create, params: user_params
          expect(User.find_by(email: user_params[:user][:email]).language).to eq('language')
        end

        it 'defaults user language to default_locale if the language isn\'t specified' do
          allow(I18n).to receive(:default_locale).and_return(:default_language)
          user_params[:user][:language] = nil
          post :create, params: user_params
          expect(User.find_by(email: user_params[:user][:email]).language).to eq('default_language')
        end
      end

      context 'activation' do
        context 'SMTP enabled' do
          it 'generates an activation token for the user' do
            freeze_time

            post :create, params: user_params
            user = User.find_by email: user_params[:user][:email]
            expect(user.verification_digest).to be_present
            expect(user.verification_sent_at).to eq(Time.current)
            expect(user).not_to be_verified
          end

          it 'sends activation email to and does not sign in the created user' do
            session[:session_token] = nil
            expect { post :create, params: user_params }.to change(User, :count).by(1)
            expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.at(:no_wait).exactly(:once).with('UserMailer', 'activate_account_email',
                                                                                                         'deliver_now', Hash)
            expect(response).to have_http_status(:created)
            expect(session[:session_token]).to be_nil
          end
        end

        context 'SMTP disabled' do
          before do
            ENV['SMTP_SERVER'] = ''
          end

          it 'marks the user as verified and signs them in' do
            post :create, params: user_params

            user = User.find_by email: user_params[:user][:email]
            expect(user).to be_verified
            expect(session[:session_token]).to eq(user.session_token)
            expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
          end
        end
      end

      context 'Authenticated request' do
        context 'Not admin creation' do
          let(:signed_in_user) { user }

          before { sign_in_user(signed_in_user) }

          it 'returns :forbidden and does NOT create the user' do
            expect { post :create, params: user_params }.not_to change(User, :count)
            expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued

            expect(response).to have_http_status(:forbidden)
            expect(session[:session_token]).to eql(signed_in_user.session_token)
          end
        end

        context 'Admin creation' do
          let(:signed_in_user) { user_with_manage_users_permission }

          before { sign_in_user(signed_in_user) }

          it 'sends activation email to but does NOT signin the created user' do
            expect { post :create, params: user_params }.to change(User, :count).by(1)
            expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.at(:no_wait).exactly(:once).with('UserMailer', 'activate_account_email',
                                                                                                         'deliver_now', Hash)
            expect(response).to have_http_status(:created)
            expect(session[:session_token]).to eql(signed_in_user.session_token)
          end

          context 'User language' do
            it 'defaults user language to admin language if the language isn\'t specified' do
              signed_in_user.update! language: 'language'

              user_params[:user][:language] = nil
              post :create, params: user_params
              expect(User.find_by(email: user_params[:user][:email]).language).to eq('language')
              expect(response).to have_http_status(:created)
              expect(session[:session_token]).to eql(signed_in_user.session_token)
            end
          end
        end
      end
    end

    context 'invalid user params' do
      it 'fails for invalid values' do
        invalid_user_params = {
          user: { name: '', email: 'invalid', password: 'something' }
        }
        expect { post :create, params: invalid_user_params }.not_to change(User, :count)

        expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['errors']).to eq(Rails.configuration.custom_error_msgs[:record_invalid])
      end

      context 'Duplicated email' do
        it 'returns :bad_request with "EmailAlreadyExists" error' do
          existent_user = create(:user)

          invalid_user_params = user_params
          invalid_user_params[:user][:email] = existent_user.email

          expect { post :create, params: invalid_user_params }.not_to change(User, :count)

          expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)['errors']).to eq(Rails.configuration.custom_error_msgs[:email_exists])
        end
      end
    end

    context 'Role mapping' do
      before do
        role_map = instance_double(SettingGetter)
        allow(SettingGetter).to receive(:new).with(setting_name: 'RoleMapping', provider: 'greenlight').and_return(role_map)
        allow(role_map).to receive(:call).and_return('Decepticons=@decepticons.cybertron,Autobots=autobots.cybertron')
      end

      it 'Creates a User and assign a role if a rule matches their email' do
        autobots = create(:role, name: 'Autobots')
        user_params = {
          name: 'Optimus Prime',
          email: 'optimus@autobots.cybertron',
          password: 'Autobots1!',
          language: 'teletraan'
        }

        expect { post :create, params: { user: user_params } }.to change(User, :count).from(0).to(1)

        expect(User.find_by(email: user_params[:email]).role).to eq(autobots)
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['errors']).to be_nil
      end
    end

    context 'Registration Method' do
      context 'invite' do
        before do
          reg_method = instance_double(SettingGetter)
          allow(SettingGetter).to receive(:new).with(setting_name: 'RegistrationMethod', provider: 'greenlight').and_return(reg_method)
          allow(reg_method).to receive(:call).and_return('invite')
        end

        it 'creates a user account if they have a valid invitation' do
          invite = create(:invitation, email: user_params[:user][:email])
          user_params[:user][:invite_token] = invite.token

          expect { post :create, params: user_params }.to change(User, :count).from(0).to(1)

          expect(response).to have_http_status(:created)
          expect(JSON.parse(response.body)['errors']).to be_nil
        end

        it 'deletes an invitation after using it' do
          invite = create(:invitation, email: user_params[:user][:email])
          user_params[:user][:invite_token] = invite.token

          expect { post :create, params: user_params }.to change(Invitation, :count).by(-1)
        end

        it 'allows an admin to create a user without a token' do
          sign_in_user(user_with_manage_users_permission)

          expect { post :create, params: user_params }.to change(User, :count).by(1)

          expect(response).to have_http_status(:created)
          expect(JSON.parse(response.body)['errors']).to be_nil
        end

        it 'returns an InviteInvalid error if no invite is passed' do
          expect { post :create, params: user_params }.not_to change(User, :count)

          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)['errors']).to eq(Rails.configuration.custom_error_msgs[:invite_token_invalid])
        end

        it 'returns an InviteInvalid error if the token is wrong' do
          user_params[:user][:invite_token] = 'fake-token'
          expect { post :create, params: user_params }.not_to change(User, :count)

          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)['errors']).to eq(Rails.configuration.custom_error_msgs[:invite_token_invalid])
        end
      end

      context 'approval' do
        before do
          reg_method = instance_double(SettingGetter)
          allow(SettingGetter).to receive(:new).with(setting_name: 'RegistrationMethod', provider: 'greenlight').and_return(reg_method)
          allow(reg_method).to receive(:call).and_return(SiteSetting::REGISTRATION_METHODS[:approval])
        end

        it 'sets a user to pending when registering' do
          expect { post :create, params: user_params }.to change(User, :count).from(0).to(1)

          expect(User.find_by(email: user_params[:user][:email])).to be_pending
        end
      end
    end

    context 'External AuthN enabled' do
      before do
        allow(controller).to receive(:external_authn_enabled?).and_return(true)
      end

      it 'returns :forbidden without creating the user account' do
        expect { post :create, params: user_params }.not_to change(User, :count)

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)['data']).to be_blank
        expect(JSON.parse(response.body)['errors']).not_to be_nil
      end
    end
  end

  describe '#show' do
    before do
      sign_in_user(user)
    end

    it 'returns a user if id is valid' do
      get :show, params: { id: user.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq(user.id)
    end
  end

  describe '#update' do
    before do
      sign_in_user(user)
    end

    it 'updates the users attributes' do
      updated_params = {
        name: 'New Name',
        language: 'gl'
      }
      patch :update, params: { id: user.id, user: updated_params }
      expect(response).to have_http_status(:ok)

      user.reload

      expect(user.name).to eq(updated_params[:name])
      expect(user.language).to eq(updated_params[:language])
    end

    it 'returns an error if the user update fails' do
      patch :update, params: { id: user.id, user: { name: nil } }
      expect(response).to have_http_status(:bad_request)
      expect(user.reload.name).to eq(user.name)
    end

    it 'updates the avatar' do
      patch :update, params: { id: user.id, user: { avatar: fixture_file_upload(file_fixture('default-avatar.png'), 'image/png') } }
      expect(user.reload.avatar).to be_attached
    end

    it 'deletes the avatar' do
      user.avatar.attach(io: fixture_file_upload('default-avatar.png'), filename: 'default-avatar.png', content_type: 'image/png')
      expect(user.reload.avatar).to be_attached
      delete :purge_avatar, params: { id: user.id }
      expect(user.reload.avatar).not_to be_attached
    end

    it 'doesnt allow a user to change their own role' do
      updated_params = {
        role_id: create(:role, name: 'New Role').id
      }
      patch :update, params: { id: user.id, user: updated_params }

      user.reload

      expect(user.role_id).not_to eq(updated_params[:role_id])
    end

    it 'allows a user to change their own name' do
      updated_params = {
        name: 'New Awesome Name'
      }

      patch :update, params: { id: user.id, user: updated_params }

      user.reload

      expect(user.name).to eq(updated_params[:name])
    end

    it 'doesnt allow a user with ManageUser permissions to edit their own role' do
      sign_in_user(user_with_manage_users_permission)

      old_role_id = user_with_manage_users_permission.role_id
      updated_params = {
        role_id: create(:role, name: 'New Role').id
      }

      patch :update, params: { id: user_with_manage_users_permission.id, user: updated_params }

      user_with_manage_users_permission.reload
      expect(response).to have_http_status(:forbidden)
      expect(user_with_manage_users_permission.role_id).to eq(old_role_id)
      expect(user_with_manage_users_permission.role_id).not_to eq(updated_params[:role_id])
    end

    it 'allows a user with ManageUser permissions to edit another users role' do
      sign_in_user(user_with_manage_users_permission)

      updated_params = {
        role_id: create(:role, name: 'New Role').id
      }
      patch :update, params: { id: user.id, user: updated_params }

      user.reload

      expect(user.role_id).to eq(updated_params[:role_id])
    end
  end

  describe '#destroy' do
    before do
      sign_in_user(user)
    end

    it 'deletes the current_user account' do
      expect(response).to have_http_status(:ok)
      expect { delete :destroy, params: { id: user.id } }.to change(User, :count).by(-1)
    end

    it 'returns status code forbidden if the user tries to delete another user' do
      new_user = create(:user)
      expect { delete :destroy, params: { id: new_user.id } }.not_to change(User, :count)
      expect(response).to have_http_status(:forbidden)
    end

    context 'user with ManageUsers permission' do
      before do
        sign_in_user(user_with_manage_users_permission)
      end

      it 'deletes a user' do
        new_user = create(:user)
        expect { delete :destroy, params: { id: new_user.id } }.to change(User, :count).by(-1)
      end

      it 'returns status code not found if the user does not exists' do
        expect { delete :destroy, params: { id: 'invalid-id' } }.not_to change(User, :count)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'change_password' do
    before do
      sign_in_user(user)
    end

    let!(:user) { create(:user, password: 'Test12345678+') }

    it 'changes current_user password if the params are valid' do
      valid_params = { old_password: 'Test12345678+', new_password: 'Glv3IsAwesome!' }
      post :change_password, params: { user: valid_params }

      expect(response).to have_http_status(:ok)
      expect(user.reload.authenticate(valid_params[:new_password])).to be_truthy
    end

    it 'returns :bad_request response for invalid old_password' do
      invalid_params = { old_password: 'NotMine!', new_password: 'ThisIsMine!' }
      post :change_password, params: { user: invalid_params }

      expect(response).to have_http_status(:bad_request)
      expect(user.reload.authenticate(invalid_params[:new_password])).to be_falsy
    end

    it 'returns :bad_request response for missing params' do
      invalid_params = { old_password: '', new_password: '' }
      post :change_password, params: { user: invalid_params }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns :unauthorized response for unauthenticated requests' do
      session[:session_token] = nil
      post :change_password, params: {}
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns :forbidden response for external accounts' do
      external_user = create(:user, external_id: 'EXTERAL_ID')
      sign_in_user(external_user)
      post :change_password, params: {}
      expect(response).to have_http_status(:forbidden)
    end
  end

  context 'private methods' do
    describe '#external_authn_enabled?' do
      before do
        allow(controller).to receive(:external_authn_enabled?).and_call_original
      end

      context 'OPENID_CONNECT_ISSUER is present?' do
        before do
          ENV['OPENID_CONNECT_ISSUER'] = 'issuer'
        end

        it 'returns true' do
          expect(controller).to be_external_authn_enabled
        end
      end

      context 'OPENID_CONNECT_ISSUER is NOT present?' do
        before do
          ENV['OPENID_CONNECT_ISSUER'] = ''
        end

        it 'returns false' do
          expect(controller).not_to be_external_authn_enabled
        end
      end
    end
  end
end
