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
        RolePermission.find_by(role: user.role, permission: Permission.find_by(name: 'CanRecord')).update(value: 'false')
      end
    end
  end
end
