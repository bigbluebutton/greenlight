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

  trait :manage_users do
    after(:create) do |user|
      FactoryBot.create(:role_permission, role: user.role, permission: FactoryBot.create(:permission, name: 'ManageUsers'), value: 'true')
    end
  end

  trait :manage_rooms do
    after(:create) do |user|
      FactoryBot.create(:role_permission, role: user.role, permission: FactoryBot.create(:permission, name: 'ManageRooms'), value: 'true')
    end
  end

  trait :manage_recordings do
    after(:create) do |user|
      FactoryBot.create(:role_permission, role: user.role, permission: FactoryBot.create(:permission, name: 'ManageRecordings'), value: 'true')
    end
  end

  trait :manage_site_settings do
    after(:create) do |user|
      FactoryBot.create(:role_permission, role: user.role, permission: FactoryBot.create(:permission, name: 'ManageSiteSettings'), value: 'true')
    end
  end

  trait :manage_roles do
    after(:create) do |user|
      FactoryBot.create(:role_permission, role: user.role, permission: FactoryBot.create(:permission, name: 'ManageRoles'), value: 'true')
    end
  end
end
