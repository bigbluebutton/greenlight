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

RSpec.describe Api::V1::Admin::RolePermissionsController, type: :controller do
  let(:user) { create(:user) }
  let(:user_with_manage_roles_permission) { create(:user, :with_manage_roles_permission) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    sign_in_user(user_with_manage_roles_permission)
  end

  describe '#index' do
    it 'returns all the RolePermissions' do
      get :index, params: { role_id: user_with_manage_roles_permission.role_id }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data']['CreateRoom']).to eq('true')
      expect(response.parsed_body['data']['RoomLimit']).to eq('100')
      expect(response.parsed_body['data']['SharedList']).to eq('true')
      expect(response.parsed_body['data']['ManageRoles']).to eq('true')
    end

    context 'user without ManageRoles permission' do
      before do
        sign_in_user(user)
      end

      it 'cant return all the RolePermissions' do
        get :index
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe '#update' do
    it 'updates the value of RolePermissions' do
      role = create(:role)
      permission = create(:permission)
      role_permission = create(:role_permission, role:, permission:, value: true)

      get :update, params: { role: { name: permission.name, role_id: role.id, value: false } }
      expect(response).to have_http_status(:ok)
      expect(role_permission.reload.value).to eq('false')
    end

    context 'user without ManageRoles permission' do
      before do
        sign_in_user(user)
      end

      it 'cant update the value of RolePermissions' do
        role = create(:role)
        permission = create(:permission)
        create(:role_permission, role:, permission:, value: true)

        get :update, params: { role: { name: permission.name, role_id: role.id, value: false } }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
