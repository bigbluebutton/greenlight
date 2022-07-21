# frozen_string_literal: true

FactoryBot.define do
  factory :rooms_configuration do
    meeting_option
    provider { Faker::Company.name.downcase }
    value { %w[true false optional].sample }
  end
end
