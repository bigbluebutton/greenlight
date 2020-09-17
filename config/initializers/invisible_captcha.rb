# frozen_string_literal: true

InvisibleCaptcha.setup do |config|
  config.timestamp_enabled = !Rails.env.test?
end
