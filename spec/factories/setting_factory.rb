# frozen_string_literal: true

FactoryBot.define do
  factory :setting do
    name { Faker::Vehicle.unique.make }
  end
end
