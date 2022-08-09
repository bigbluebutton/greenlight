# frozen_string_literal: true

FactoryBot.define do
  factory :role_permission do
    value { Faker::Boolean.boolean }
    role
    permission
  end
end
