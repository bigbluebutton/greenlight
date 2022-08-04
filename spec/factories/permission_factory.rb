# frozen_string_literal: true

FactoryBot.define do
  factory :permission do
    name { Faker::App.name }
  end
end
