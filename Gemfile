# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.0'

gem 'bcrypt', '~> 3.1.7'
gem 'bigbluebutton-api-ruby', '1.8'
gem 'bootsnap', require: false
gem 'cssbundling-rails'
gem 'data_migrate'
gem 'dotenv-rails'
gem 'jbuilder'
gem 'jsbundling-rails'
gem 'hcaptcha'
gem 'pg'
gem 'puma', '~> 5.0'
gem 'rails', '~> 7.0.2', '>= 7.0.2.2'
gem 'sprockets-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"
# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"
# Use Sass to process CSS
# gem "sassc-rails"
# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'rubocop', '~> 1.26', require: false
  gem 'rubocop-performance', '~> 1.13', require: false
  gem 'rubocop-rails', '~> 2.13', require: false
  gem 'rubocop-rspec', '~> 2.9.0', require: false

  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'webdrivers'
end
