# frozen_string_literal: true

# config/initializers/hcaptcha.rb

Hcaptcha.configure do |config|
  config.site_key = ENV.fetch('HCAPTCHA_SITE_KEY', nil)
  config.secret_key = ENV.fetch('HCAPTCHA_SECRET_KEY', nil)
  # # optional, default value = https://hcaptcha.com/siteverify
  # config.verify_url = 'VERIFY_URL'
  # # optional, default value = https://hcaptcha.com/1/api.js
  # config.api_script_url = 'API_SCRIPT_URL'
end
