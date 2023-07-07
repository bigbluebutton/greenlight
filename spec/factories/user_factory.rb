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

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    external_id { nil }
    provider { 'greenlight' }
    password { 'Password1!' }
    role
    last_login { nil }
    status { 0 }
    language { %w[en fr es ar].sample }
    verified { true }

    trait :with_super_admin do
      after(:create) do |user|
        user.provider = 'bn'
        user.role = create(:role, :with_super_admin)
        user.save
      end
    end

    trait :with_manage_users_permission do
      after(:create) do |user|
        create(:role_permission, role: user.role, permission: create(:permission, name: 'ManageUsers'), value: 'true')
      end
    end

    trait :with_manage_rooms_permission do
      after(:create) do |user|
        create(:role_permission, role: user.role, permission: create(:permission, name: 'ManageRooms'), value: 'true')
      end
    end

    trait :with_manage_recordings_permission do
      after(:create) do |user|
        create(:role_permission, role: user.role, permission: create(:permission, name: 'ManageRecordings'), value: 'true')
      end
    end

    trait :with_manage_site_settings_permission do
      after(:create) do |user|
        create(:role_permission, role: user.role, permission: create(:permission, name: 'ManageSiteSettings'), value: 'true')
      end
    end

    trait :with_manage_roles_permission do
      after(:create) do |user|
        create(:role_permission, role: user.role, permission: create(:permission, name: 'ManageRoles'), value: 'true')
      end
    end

    trait :without_shared_list_permission do
      after(:create) do |user|
        RolePermission.find_by(role: user.role, permission: Permission.find_by(name: 'SharedList')).update(value: 'false')
      end
    end

    trait :without_create_room_permission do
      after(:create) do |user|
        RolePermission.find_by(role: user.role, permission: Permission.find_by(name: 'CreateRoom')).update(value: 'false')
      end
    end

    trait :without_can_record_permission do
      after(:create) do |user|
        RolePermission.find_or_create_by(role: user.role, permission: Permission.find_or_create_by(name: 'CanRecord')).update(value: 'false')
      end
    end
  end
end
