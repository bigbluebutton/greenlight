# frozen_string_literal: true

FactoryBot.define do
  factory :recording do
    room
    name { Faker::Educator.course_name }
    record_id { Faker::Internet.uuid }
    visibility { 'Unpublished' }
    length { Faker::Number.within(range: 1..60) }
    participants { Faker::Number.within(range: 1..100) }

    after(:create) do |recording|
      create(:format, recording:)
    end
  end
end
