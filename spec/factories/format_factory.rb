# frozen_string_literal: true

FactoryBot.define do
  factory :format do
    recording
    recording_type { 'Presentation' }
    url { Faker::Internet.url }
  end
end
