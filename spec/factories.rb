# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    password = Faker::Internet.password(8)

    provider { %w(greenlight google twitter).sample }
    uid { rand(10**8) }
    name { Faker::Name.first_name }
    username { Faker::Internet.user_name }
    email { Faker::Internet.email }
    password { password }
    password_confirmation { password }
  end

  factory :room do
    name { Faker::Pokemon.name }
    owner { create(:user) }
  end
end
