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
        record_id: '',
        current_provider: user.provider
      ).call).to be(true)
    end

    it 'returns false if the user role does not have the provided permission' do
      create(:role_permission, role:, permission:, value: 'false')
      expect(described_class.new(
        current_user: user,
        permission_names: permission.name,
        user_id: '',
        friendly_id: '',
        record_id: '',
        current_provider: user.provider
      ).call).to be(false)
    end

    it 'returns true if the user is trying to act on itself without having the ManageUsers permission' do
      create(:role_permission, role:, permission:, value: 'false')
      expect(described_class.new(
        current_user: user,
        permission_names: 'ManageUsers',
        user_id: user.id,
        friendly_id: '',
        record_id: '',
        current_provider: user.provider
      ).call).to be(true)
    end

    it 'returns false if the users status is not active' do
      banned_user = create(:user, status: :banned)
      expect(described_class.new(
        current_user: banned_user,
        permission_names: permission.name,
        user_id: '',
        friendly_id: '',
        record_id: '',
        current_provider: user.provider
      ).call).to be(false)
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
          record_id: '',
          current_provider: user.provider
        ).call).to be(true)
      end

      it 'checks multiple actions and returns true if the user is acting on themself' do
        expect(described_class.new(
          current_user: user,
          permission_names: %w[ManageRoles ManageRooms ManageUsers],
          user_id: user.id,
          friendly_id: '',
          record_id: '',
          current_provider: user.provider
        ).call).to be(true)
      end

      it 'checks the users role and returns true since user has SuperAdmin role' do
        super_admin_role = create(:role, name: 'SuperAdmin', provider: 'bn')
        super_admin_user = create(:user, provider: 'bn', role: super_admin_role)
        expect(described_class.new(
          current_user: super_admin_user,
          permission_names: [],
          user_id: super_admin_user.id,
          friendly_id: '',
          record_id: '',
          current_provider: super_admin_user.provider
        ).call).to be(true)
      end

      context 'Current Provider Checks' do
        it 'checks the current user provider and returns false if not equal to current provider' do
          role = create(:role, provider: 'bn')
          user_bn_provider = create(:user, provider: 'bn', role:)
          expect(described_class.new(
            current_user: user_bn_provider,
            permission_names: [],
            user_id: '',
            friendly_id: '',
            record_id: '',
            current_provider: user.provider
          ).call).to be(false)
        end

        it 'checks the current user provider and returns false if the provider is not equal to user\'s provider' do
          role = create(:role, provider: 'bn')
          user_bn_provider = create(:user, provider: 'bn', role:)
          expect(described_class.new(
            current_user: user_bn_provider,
            permission_names: [],
            user_id: user.id,
            friendly_id: '',
            record_id: '',
            current_provider: user_bn_provider.provider
          ).call).to be(false)
        end

        it 'checks the current user provider and returns false if the provider is not equal to rooms\'s user provider' do
          role = create(:role, provider: 'bn')
          user_bn_provider = create(:user, provider: 'bn', role:)
          room = create(:room, user:)
          expect(described_class.new(
            current_user: user_bn_provider,
            permission_names: [],
            user_id: '',
            friendly_id: room.friendly_id,
            record_id: '',
            current_provider: user_bn_provider.provider
          ).call).to be(false)
        end

        it 'checks the current user provider and returns false if the provider is not equal to the recording\'s user provider' do
          role = create(:role, provider: 'bn')
          user_bn_provider = create(:user, provider: 'bn', role:)
          room = create(:room, user:)
          recording = create(:recording, room:)
          expect(described_class.new(
            current_user: user_bn_provider,
            permission_names: [],
            user_id: '',
            friendly_id: '',
            record_id: recording.record_id,
            current_provider: user_bn_provider.provider
          ).call).to be(false)
        end
      end
    end
  end
end
