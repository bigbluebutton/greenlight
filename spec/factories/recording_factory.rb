# frozen_string_literal: true

FactoryBot.define do
  factory :recording do
    room
    name { Faker::Educator.course_name }
    record_id { Faker::Internet.uuid }
  end
end
