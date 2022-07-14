# frozen_string_literal: true

FactoryBot.define do
  factory :site_setting do
    setting
    provider { Faker::Company.name.downcase }
    value { [true, false, '12345'].sample }
  end
end
