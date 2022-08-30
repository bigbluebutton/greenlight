# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    external_id { nil }
    provider { 'greenlight' }
    password { Faker::Internet.password }
    role
    last_login { nil }
    language { %w[en fr es ar].sample }
  end

  trait :with_manage_users_permission do
    after(:create) do |user|
      FactoryBot.create(:role_permission, role: user.role, permission: FactoryBot.create(:permission, name: 'ManageUsers'), value: 'true')
    end
  end

  trait :with_manage_rooms_permission do
    after(:create) do |user|
      FactoryBot.create(:role_permission, role: user.role, permission: FactoryBot.create(:permission, name: 'ManageRooms'), value: 'true')
    end
  end

  trait :with_manage_recordings_permission do
    after(:create) do |user|
      FactoryBot.create(:role_permission, role: user.role, permission: FactoryBot.create(:permission, name: 'ManageRecordings'), value: 'true')
    end
  end

  trait :with_manage_site_settings_permission do
    after(:create) do |user|
      FactoryBot.create(:role_permission, role: user.role, permission: FactoryBot.create(:permission, name: 'ManageSiteSettings'), value: 'true')
    end
  end

  trait :with_manage_roles_permission do
    after(:create) do |user|
      FactoryBot.create(:role_permission, role: user.role, permission: FactoryBot.create(:permission, name: 'ManageRoles'), value: 'true')
    end
  end

  trait :with_shared_list_permission do
    after(:create) do |user|
      FactoryBot.create(:role_permission, role: user.role, permission: FactoryBot.create(:permission, name: 'SharedList'), value: 'true')
    end
  end

  trait :with_create_room_permission do
    after(:create) do |user|
      FactoryBot.create(:role_permission, role: user.role, permission: FactoryBot.create(:permission, name: 'CreateRoom'), value: 'true')
    end
  end

  trait :can_record do
    after(:create) do |user|
      FactoryBot.create(:role_permission, role: user.role, permission: FactoryBot.create(:permission, name: 'CanRecord'), value: 'true')
    end
  end

  trait :cant_record do
    after(:create) do |user|
      FactoryBot.create(:role_permission, role: user.role, permission: FactoryBot.create(:permission, name: 'CanRecord'), value: 'false')
    end
  end
end
