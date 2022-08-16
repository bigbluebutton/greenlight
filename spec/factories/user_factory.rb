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
end
