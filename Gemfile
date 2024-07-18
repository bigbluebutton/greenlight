# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '>= 3.0'

gem 'active_model_serializers', '>= 0.10.14'
gem 'active_storage_validations', '>= 1.1.0'
gem 'aws-sdk-s3', require: false
gem 'bcrypt', '~> 3.1.7'
gem 'bigbluebutton-api-ruby', '1.9.1'
gem 'bootsnap', require: false
gem 'clamby', '~> 1.6.10'
gem 'cssbundling-rails', '>= 1.3.3'
gem 'data_migrate', '>= 9.4.0'
gem 'dotenv-rails'
gem 'google-cloud-storage', '~> 1.45', '>= 1.45.0', require: false
gem 'hcaptcha'
gem 'hiredis', '~> 0.6.0'
gem 'i18n-language-mapping'
gem 'image_processing', '~> 1.2'
gem 'jbuilder'
gem 'jsbundling-rails', '>= 1.2.2'
gem 'jwt'
gem 'mini_magick', '>= 4.9.5'
gem 'omniauth', '~> 2.1.2'
gem 'omniauth_openid_connect', '>= 0.6.1'
gem 'omniauth-rails_csrf_protection', '~> 1.0.2'
gem 'pagy', '~> 6.0', '>= 6.0.0'
gem 'pg'
gem 'puma', '~> 5.6'
gem 'rails', '~> 7.1.3', '>= 7.1.3.3'
gem 'redis', '~> 4.0'
gem 'sprockets-rails', '>= 3.5.0'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'rubocop', '~> 1.56', '>= 1.56.2', require: false
  gem 'rubocop-capybara', '~> 2.20.0', require: false
  gem 'rubocop-factory_bot', '~> 2.25.0', require: false
  gem 'rubocop-performance', '~> 1.17', '>= 1.17.0', require: false
  gem 'rubocop-rails', '~> 2.21', '>= 2.21.0', require: false
  gem 'rubocop-rspec', '~> 2.10.0', require: false
  gem 'web-console', '>= 4.2.1'
end

group :test do
  gem 'capybara'
  gem 'factory_bot', '>= 6.4.1'
  gem 'factory_bot_rails', '>= 6.4.3'
  gem 'faker'
  gem 'rspec-rails', '>= 6.0.4'
  gem 'selenium-webdriver', '>= 4.8.1'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'webdrivers', '>= 5.3.0'
  gem 'webmock', '>= 3.19.0'
end

group :production do
  gem 'lograge', '~> 0.14.0'
  gem 'remote_syslog_logger'
end
