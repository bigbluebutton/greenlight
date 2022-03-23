# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    external_id { nil }
    provider { Faker::Company.name.downcase }
    password { Faker::Internet.password }
    password_confirmation { password } # For password confirmation validation.
    last_login { nil }
  end
end
