# frozen_string_literal: true

require 'rails_helper'

describe RoleCreator, type: :service do
  describe '#call' do
    before do
      create(:permission, name: 'CreateRoom')
      create(:permission, name: 'ManageUsers')
      create(:permission, name: 'ManageRooms')
      create(:permission, name: 'ManageRecordings')
      create(:permission, name: 'ManageSiteSettings')
      create(:permission, name: 'ManageRoles')
      create(:permission, name: 'SharedList')
      create(:permission, name: 'CanRecord')
      create(:permission, name: 'RoomLimit')
    end

    it 'creates a role with the provided name' do
      role_params = { name: 'New Role' }
      role = described_class.new(name: role_params[:name], provider: 'greenlight').call

      expect(role).to be_instance_of(Role)
      expect(role.name).to eq(role_params[:name])
      expect(role.provider).to eq('greenlight')
      expect(role).to be_valid
    end

    it 'creates a role with all permissions set to false' do
      role_params = { name: 'New Role' }
      role = described_class.new(name: role_params[:name], provider: 'greenlight').call

      expect(role.role_permissions.pluck(:value)).to eq(%w[false false false false false false false false 0])
    end
  end
end
