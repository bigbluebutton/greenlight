# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    name { Faker::Job.unique.title }
    provider { 'greenlight' }

    after(:create) do |role|
      perm = Permission.find_or_create_by(name: 'CreateRoom')
      perm2 = Permission.find_or_create_by(name: 'RoomLimit')
      perm3 = Permission.find_or_create_by(name: 'SharedList')
      RolePermission.find_or_create_by(permission: perm, role:, value: 'true')
      RolePermission.find_or_create_by(permission: perm2, role:, value: '100')
      RolePermission.find_or_create_by(permission: perm3, role:, value: 'true')
    end
  end
end
