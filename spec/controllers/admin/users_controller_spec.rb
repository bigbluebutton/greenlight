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

RSpec.describe Api::V1::Admin::UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:user_with_manage_users_permission) { create(:user, :with_manage_users_permission) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    sign_in_user(user_with_manage_users_permission)
  end

  describe '#verified_users' do
    it 'returns the list of active users' do
      users = create_list(:user, 3, status: 'active') + [user, user_with_manage_users_permission]
      get :verified
      expect(response).to have_http_status(:ok)
      response_user_ids = response.parsed_body['data'].pluck('id')
      expect(response_user_ids).to match_array(users.pluck(:id))
    end

    it 'excludes users with a different provider' do
      greenlight_users = create_list(:user, 3, provider: 'greenlight') + [user_with_manage_users_permission]
      role_with_provider_test = create(:role, provider: 'test')
      create(:user, provider: 'test', role: role_with_provider_test)

      get :verified

      expect(response.parsed_body['data'].pluck('id')).to match_array(greenlight_users.pluck(:id))
    end
  end

  describe '#unverified_users' do
    it 'returns the list of unverified users' do
      users = create_list(:user, 3, verified: false)
      get :unverified
      expect(response).to have_http_status(:ok)
      response_user_ids = response.parsed_body['data'].pluck('id')
      expect(response_user_ids).to match_array(users.pluck(:id))
    end

    it 'excludes users with a different provider' do
      greenlight_users = create_list(:user, 3, provider: 'greenlight', verified: false)
      role_with_provider_test = create(:role, provider: 'test')
      create(:user, provider: 'test', role: role_with_provider_test, verified: false)
      get :unverified
      expect(response.parsed_body['data'].pluck('id')).to match_array(greenlight_users.pluck(:id))
    end
  end

  describe '#pending' do
    it 'returns a list of pending users' do
      users = create_list(:user, 3, status: 'pending')

      get :pending

      expect(response.parsed_body['data'].pluck('id')).to match_array(users.pluck(:id))
    end

    context 'user without ManageUsers permission' do
      before do
        sign_in_user(user)
      end

      it 'returns :forbidden for user without ManageUsers permission' do
        get :pending
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe '#banned' do
    it 'returns a list of pending users' do
      users = create_list(:user, 3, status: 'banned')

      get :banned

      expect(response.parsed_body['data'].pluck('id')).to match_array(users.pluck(:id))
    end

    context 'user without ManageUsers permission' do
      before do
        sign_in_user(user)
      end

      it 'returns :forbidden for user without ManageUsers permission' do
        get :banned
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe '#verified/banned/pending for SuperAdmin' do
    context 'SuperAdmin accessing users for provider other than current provider' do
      before do
        super_admin_role = create(:role, provider: 'bn', name: 'SuperAdmin')
        super_admin = create(:user, provider: 'bn', role: super_admin_role)
        sign_in_user(super_admin)
      end

      it 'returns the list of active users' do
        users = create_list(:user, 3, status: 'active') + [user, user_with_manage_users_permission]
        get :verified
        expect(response).to have_http_status(:ok)
        response_user_ids = response.parsed_body['data'].pluck('id')
        expect(response_user_ids).to match_array(users.pluck(:id))
      end

      it 'returns the list of unverified users' do
        users = create_list(:user, 3, verified: false)
        get :unverified
        expect(response).to have_http_status(:ok)
        response_user_ids = response.parsed_body['data'].pluck('id')
        expect(response_user_ids).to match_array(users.pluck(:id))
      end

      it 'returns the list of pending users' do
        users = create_list(:user, 3, status: 'pending')
        get :pending
        expect(response).to have_http_status(:ok)
        response_user_ids = response.parsed_body['data'].pluck('id')
        expect(response_user_ids).to match_array(users.pluck(:id))
      end

      it 'returns the list of banned users' do
        users = create_list(:user, 3, status: 'banned')
        get :banned
        expect(response).to have_http_status(:ok)
        response_user_ids = response.parsed_body['data'].pluck('id')
        expect(response_user_ids).to match_array(users.pluck(:id))
      end
    end
  end

  describe '#update' do
    it 'updates a users status' do
      post :update, params: { id: user.id, user: { status: 'banned' } }

      expect(user.reload.status).to eq('banned')
    end

    it 'verifies an unverified user' do
      unverified_user = create(:user, verified: false)
      post :update, params: { id: unverified_user.id, user: { verified: true } }
      unverified_user.reload
      expect(response).to have_http_status(:ok)
      expect(unverified_user.verified).to be(true)
    end

    context 'user without ManageUsers permission' do
      before do
        sign_in_user(user)
      end

      it 'returns :forbidden for user without ManageUsers permission' do
        post :update, params: { id: user.id, user: { status: 'banned' } }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
