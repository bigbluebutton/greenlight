# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '>= 3.0'

gem 'active_model_serializers'
gem 'active_storage_validations', '>= 1.0.4'
gem 'aws-sdk-s3', require: false
gem 'bcrypt', '~> 3.1.7'
gem 'bigbluebutton-api-ruby', '1.9.1'
gem 'bootsnap', require: false
gem 'cssbundling-rails', '>= 1.2.0'
gem 'data_migrate', '>= 9.0.0'
gem 'dotenv-rails'
gem 'hcaptcha'
gem 'hiredis', '~> 0.6.0'
gem 'i18n-language-mapping'
gem 'image_processing', '~> 1.2'
gem 'jbuilder'
gem 'jsbundling-rails', '>= 1.1.2'
gem 'jwt'
gem 'mini_magick', '>= 4.9.5'
gem 'omniauth', '~> 2.1.0'
gem 'omniauth_openid_connect'
gem 'omniauth-rails_csrf_protection', '~> 1.0.1'
gem 'pagy', '~> 5.10', '>= 5.10.1'
gem 'pg'
gem 'puma', '~> 5.0'
gem 'rails', '~> 7.0.5', '>= 7.0.5.1'
gem 'redis', '~> 4.0'
gem 'sprockets-rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'rubocop', '~> 1.26', require: false
  gem 'rubocop-performance', '~> 1.13', require: false
  gem 'rubocop-rails', '~> 2.17', '>= 2.17.4', require: false
  gem 'rubocop-rspec', '~> 2.9.0', require: false
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails', '>= 6.0.2'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'webdrivers'
  gem 'webmock'
end

group :production do
  gem 'lograge', '~> 0.12.0'
  gem 'remote_syslog_logger'
end
