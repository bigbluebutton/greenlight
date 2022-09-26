# frozen_string_literal: true

FactoryBot.define do
  factory :meeting_option do
    name { Faker::Lorem.unique.word }
    default_value { [true, false, '12345'].sample }
  end
end
