# frozen_string_literal: true

require 'rails_helper'

describe PermissionsChecker, type: :service do
  let(:role) { create(:role) }
  let(:permission) { create(:permission) }
  let(:user) { create(:user, role:) }

  describe '#call' do
    it 'returns true if the user role has the provided permission' do
      create(:role_permission, role:, permission:, value: 'true', provider: 'greenlight')
      expect(described_class.new(current_user: user, permission_name: permission.name).call).to be(true)
    end

    it 'returns false if the user role does not have the provided permission' do
      create(:role_permission, role:, permission:, value: 'false', provider: 'greenlight')
      expect(described_class.new(current_user: user, permission_name: permission.name).call).to be(false)
    end

    it 'returns true if the user is trying to act on itself without having the ManageUsers permission' do
      create(:role_permission, role:, permission:, value: 'false', provider: 'greenlight')
      expect(described_class.new(current_user: user, permission_name: 'ManageUsers', user_id: user.id).call).to be(true)
    end
  end
end
