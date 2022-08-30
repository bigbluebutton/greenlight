# frozen_string_literal: true

require 'rails_helper'

describe PermissionsChecker, type: :service do
  let(:role) { create(:role) }
  let(:permission) { create(:permission) }
  let(:user) { create(:user, role:) }

  describe '#call' do
    it 'returns true if the user role has the provided permission' do
      create(:role_permission, role:, permission:, value: 'true')
      expect(described_class.new(
        current_user: user,
        permission_names: permission.name,
        user_id: '',
        friendly_id: '',
        record_id: ''
      ).call).to be(true)
    end

    it 'returns false if the user role does not have the provided permission' do
      create(:role_permission, role:, permission:, value: 'false')
      expect(described_class.new(
        current_user: user,
        permission_names: permission.name,
        user_id: '',
        friendly_id: '',
        record_id: ''
      ).call).to be(false)
    end

    it 'returns true if the user is trying to act on itself without having the ManageUsers permission' do
      create(:role_permission, role:, permission:, value: 'false')
      expect(described_class.new(
        current_user: user,
        permission_names: 'ManageUsers',
        user_id: user.id,
        friendly_id: '',
        record_id: ''
      ).call).to be(true)
    end

    context 'multiple permission names' do
      let(:permission2) { create(:permission) }

      it 'returns true if multiple permission names are passed and one is true' do
        create(:role_permission, role:, permission:, value: 'false')
        create(:role_permission, role:, permission: permission2, value: 'true')

        expect(described_class.new(
          current_user: user,
          permission_names: [permission.name, permission2.name],
          user_id: user.id,
          friendly_id: '',
          record_id: ''
        ).call).to be(true)
      end

      it 'checks multiple actions and returns true if the user is acting on themself' do
        expect(described_class.new(
          current_user: user,
          permission_names: %w[ManageRoles ManageRooms ManageUsers],
          user_id: user.id,
          friendly_id: '',
          record_id: ''
        ).call).to be(true)
      end
    end
  end
end
