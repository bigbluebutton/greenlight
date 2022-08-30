# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::RolePermissionsController, type: :controller do
  let(:user) { create(:user) }
  let(:user_with_manage_roles_permission) { create(:user, :with_manage_roles_permission) }

  before do
    request.headers['ACCEPT'] = 'application/json'
    session[:user_id] = user_with_manage_roles_permission.id
  end

  describe '#index' do
    # TODO: - Need to find way to test using returned hash from index
    it 'returns all the SiteSettings' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    context 'user without ManageRoles permission' do
      before do
        session[:user_id] = user.id
      end

      it 'cant return all the SiteSettings' do
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
        session[:user_id] = user.id
      end

      it 'cant update the value of SiteSetting' do
        role = create(:role)
        permission = create(:permission)
        create(:role_permission, role:, permission:, value: true)

        get :update, params: { role: { name: permission.name, role_id: role.id, value: false } }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
