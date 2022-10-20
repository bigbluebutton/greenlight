# frozen_string_literal: true

FactoryBot.define do
  factory :invitation do
    email { Faker::Internet.email }
    provider { 'greenlight' }
    token { Faker::Internet.uuid }
  end
end
