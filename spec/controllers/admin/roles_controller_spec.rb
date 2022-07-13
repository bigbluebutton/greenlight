# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::RolesController, type: :controller do
  before { request.headers['ACCEPT'] = 'application/json' }

  describe 'roles#index' do
    it 'returns the list of roles' do
      roles = [create(:role, name: 'Hokage'), create(:role, name: 'Jonin'), create(:role, name: 'Chunin'), create(:role, name: 'Genin')]
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data'].pluck('id')).to match_array(roles.pluck(:id))
    end

    it 'returns the roles according to the query' do
      search_roles = [create(:role, name: 'Role 1'), create(:role, name: 'ROLE 2'), create(:role, name: 'role 3')]

      create_list(:role, 3)

      get :index, params: { search: 'role' }
      expect(JSON.parse(response.body)['data'].pluck('id')).to match_array(search_roles.pluck(:id))
    end

    it 'returns all roles if the search bar is empty' do
      create_list(:role, 5)

      get :index, params: { search: '' }
      expect(JSON.parse(response.body)['data'].pluck('id')).to match_array(Role.pluck(:id))
    end

    context 'ordering' do
      before do
        create(:role, name: 'M')
        create(:role, name: 'P')
        create(:role, name: 'I')
      end

      it 'orders the roles list by column and direction DESC' do
        get :index, params: { sort: { column: 'name', direction: 'DESC' } }
        expect(response).to have_http_status(:ok)
        # Order is important match_array isn't adequate for this test.
        expect(JSON.parse(response.body)['data'].pluck('name')).to eq(%w[P M I])
      end

      it 'orders the roles list by column and direction ASC' do
        get :index, params: { sort: { column: 'name', direction: 'ASC' } }
        expect(response).to have_http_status(:ok)
        # Order is important match_array isn't adequate for this test.
        expect(JSON.parse(response.body)['data'].pluck('name')).to eq(%w[I M P])
      end
    end
  end

  describe 'roles#create' do
    it 'returns :created and creates a role for valid params' do
      valid_params = { name: 'CrazyRole' }
      expect { post :create, params: { role: valid_params } }.to change(Role, :count).from(0).to(1)
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['errors']).to be_empty
    end

    it 'returns :bad_request for invalid params' do
      invalid_params = { name: '' }
      post :create, params: { not_role: invalid_params }
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)['errors']).not_to be_empty
    end
  end

  describe 'roles#update' do
    let!(:role) { create(:role) }

    it 'returns :ok and updates a role for valid params' do
      valid_params = { name: 'CrazyRole' }
      post :update, params: { id: role.id, role: valid_params }
      expect(role.reload.name).to eq(valid_params[:name])
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['errors']).to be_empty
    end

    it 'returns :not_found for unfound roles' do
      valid_params = { name: 'CrazyRole' }
      post :update, params: { id: 'INVALID_ID', role: valid_params }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns :bad_request for invalid params' do
      invalid_params = { name: '' }
      post :update, params: { id: role.id, not_role: invalid_params }
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)['errors']).not_to be_empty
    end
  end

  describe 'roles#show' do
    it 'returns the role for valid params' do
      role = create(:role)
      get :show, params: { id: role.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['id']).to eq(role.id)
    end

    it 'returns :not_found for unfound roles' do
      create(:role)
      get :show, params: { id: 'Invalid' }
      expect(response).to have_http_status(:not_found)
    end
  end
end
