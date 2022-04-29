# frozen_string_literal: true

FactoryBot.define do
  factory :meeting_option do
    name { Faker::Types.unique.rb_string }
    default_value { Faker::Types.rb_string }
  end
end
