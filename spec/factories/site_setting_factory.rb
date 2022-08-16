# frozen_string_literal: true

FactoryBot.define do
  factory :site_setting do
    setting
    provider { 'greenlight' }
    value { [true, false, '12345'].sample }
  end
end
