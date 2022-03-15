# frozen_string_literal: true

FactoryBot.define do
  factory :room do
    user
    name { Faker::Educator.course_name }
    last_session { nil }
    # meeting_id & friendly_id are set automatically using before_validation
  end
end
