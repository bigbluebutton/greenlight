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
        email: 'newemail@gmail.com',
        lang: 'en'
      }
      user = create(:user)
      patch :update, params: { id: user.id, user: updated_params }
      user.reload
      expect(response).to have_http_status(:ok)
      expect(user.name).to eq(updated_params[:name])
      expect(user.email).to eq(updated_params[:email])
      expect(user.lang).to eq(updated_params[:lang])
    end

    it 'returns an error if the user update fails' do
      user = create(:user)
      patch :update, params: { id: user.id, user: { name: nil } }
      expect(response).to have_http_status(:bad_request)
      expect(user.reload.name).to eq(user.name)
    end

    it 'updates the avatar' do
      user = create(:user)
      patch :update, params: { id: user.id, user: { avatar: fixture_file_upload(file_fixture('default-avatar.png'), 'image/png') } }
      expect(user.reload.avatar).to be_attached
    end

    it 'deletes the avatar' do
      user = create(:user)
      user.avatar.attach(io: fixture_file_upload('default-avatar.png'), filename: 'default-avatar.png', content_type: 'image/png')
      expect(user.reload.avatar).to be_attached
      delete :purge_avatar, params: { id: user.id }
      expect(user.reload.avatar).not_to be_attached
    end

    it 'returns an error if the avatar is a pdf' do
      user = create(:user)
      patch :update, params: { id: user.id, user: { avatar: fixture_file_upload(file_fixture('default-pdf.pdf'), 'pdf') } }
      expect(user.reload.avatar).not_to be_attached
    end

    it 'returns an error if the avatar size is too large' do
      user = create(:user)
      patch :update, params: { id: user.id, user: { avatar: fixture_file_upload(file_fixture('large-avatar.jpg'), 'jpg') } }
      expect(user.reload.avatar).not_to be_attached
    end
  end

  describe 'DELETE users#destroy' do
    it 'deletes the user' do
      user = create(:user)
      expect(response).to have_http_status(:ok)
      expect { delete :destroy, params: { id: user.id } }.to change(User, :count).by(-1)
    end

    it 'does not delete any user if the user id is invalid' do
      expect { delete :destroy, params: { id: 'invalid-id' } }.not_to change(User, :count)
      expect(response).to have_http_status(:not_found)
    end
  end
end
