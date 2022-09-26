# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:user_with_manage_users_permission) { create(:user, :with_manage_users_permission) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    sign_in_user(user)
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

    it 'creates a current_user if a new user is created' do
      session[:session_token] = nil
      create(:role, name: 'User') # Needed for admin#create
      expect { post :create, params: user_params }.to change(User, :count).by(1)
      expect(session[:session_token]).to be_present
    end

    it 'creates a user without changing the current user if the user is created from a logged in user' do
      create(:role, name: 'User') # Needed for admin#create
      expect { post :create, params: user_params }.to change(User, :count).by(1)
      expect(session[:session_token]).to be_present
    end
  end

  describe '#show' do
    it 'returns a user if id is valid' do
      user = create(:user)
      get :show, params: { id: user.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq(user.id)
    end

    it 'returns :not_found if the user doesnt exist' do
      get :show, params: { id: 'invalid__id' }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['data']).to be_nil
    end
  end

  describe '#update' do
    it 'updates the users attributes' do
      updated_params = {
        name: 'New Name',
        email: 'newemail@gmail.com',
        language: 'gl',
        role_id: create(:role, name: 'New Role').id
      }
      patch :update, params: { id: user.id, user: updated_params }
      expect(response).to have_http_status(:ok)

      user.reload

      expect(user.name).to eq(updated_params[:name])
      expect(user.email).to eq(updated_params[:email])
      expect(user.language).to eq(updated_params[:language])
      expect(user.role_id).to eq(updated_params[:role_id])
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

    it 'returns an error if the avatar is a pdf' do
      patch :update, params: { id: user.id, user: { avatar: fixture_file_upload(file_fixture('default-pdf.pdf'), 'pdf') } }
      expect(user.reload.avatar).not_to be_attached
    end

    it 'returns an error if the avatar size is too large' do
      patch :update, params: { id: user.id, user: { avatar: fixture_file_upload(file_fixture('large-avatar.jpg'), 'jpg') } }
      expect(user.reload.avatar).not_to be_attached
    end
  end

  describe '#destroy' do
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
end
