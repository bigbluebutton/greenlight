# frozen_string_literal: true

# config/initializers/hcaptcha.rb

Hcaptcha.configure do |config|
  config.site_key = 'deafadd9-444a-4025-bb80-86e83cd3aed2'
  config.secret_key = '0xf0422B999488FFa66dB89CDCda1923d939574Cd4'
  # # optional, default value = https://hcaptcha.com/siteverify
  # config.verify_url = 'VERIFY_URL'
  # # optional, default value = https://hcaptcha.com/1/api.js
  # config.api_script_url = 'API_SCRIPT_URL'
end
