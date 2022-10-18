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
    language { %w[en fr es ar].sample }

    after(:create) do |user|
      create(:role_permission, role: user.role, permission: create(:permission, name: 'CreateRoom'), value: 'true')
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

    trait :with_shared_list_permission do
      after(:create) do |user|
        create(:role_permission, role: user.role, permission: create(:permission, name: 'SharedList'), value: 'true')
      end
    end

    trait :can_record do
      after(:create) do |user|
        create(:role_permission, role: user.role, permission: create(:permission, name: 'CanRecord'), value: 'true')
      end
    end

    trait :with_roomLimit_100_permission do
      after(:create) do |user|
        create(:role_permission, role: user.role, permission: create(:permission, name: 'RoomLimit'), value: '100')
      end
    end

    trait :with_roomLimit_3_permission do
      after(:create) do |user|
        create(:role_permission, role: user.role, permission: create(:permission, name: 'RoomLimit'), value: '3')
      end
    end

    trait :without_create_room_permission do
      after(:create) do |user|
        create(:role_permission, role: user.role, permission: create(:permission, name: 'CreateRoom'), value: 'false')
      end
    end

    trait :without_can_record do
      after(:create) do |user|
        create(:role_permission, role: user.role, permission: create(:permission, name: 'CanRecord'), value: 'false')
      end
    end
  end
end
