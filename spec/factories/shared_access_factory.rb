# frozen_string_literal: true

FactoryBot.define do
  factory :shared_access do
    user
    room
  end
end
