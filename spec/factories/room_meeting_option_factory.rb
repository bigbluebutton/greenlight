# frozen_string_literal: true

FactoryBot.define do
  factory :room_meeting_option do
    room
    meeting_option
    value { [true, false, '12345'].sample }
  end
end
