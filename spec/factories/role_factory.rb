# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    name { Faker::Lorem.unique.characters(number: 10).capitalize }
    provider { 'greenlight' }
  end
end
