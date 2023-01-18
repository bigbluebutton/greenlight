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
      expect(JSON.parse(response.body)['data']['CreateRoom']).to eq('true')
      expect(JSON.parse(response.body)['data']['RoomLimit']).to eq('100')
      expect(JSON.parse(response.body)['data']['SharedList']).to eq('true')
      expect(JSON.parse(response.body)['data']['ManageRoles']).to eq('true')
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
