# frozen_string_literal: true

FactoryBot.define do
  factory :recording do
    room
    name { Faker::Educator.course_name }
    record_id { Faker::Internet.uuid }
    visibility { 'Unlisted' }
    length { Faker::Number.within(range: 1..60) }
    participants { Faker::Number.within(range: 1..100) }
  end
end
