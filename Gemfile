# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.4.3'

# Use Puma as the app server
gem 'puma', '~> 3.12'

# Use SCSS for stylesheets
gem 'sassc-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.4'
gem 'jquery-ui-rails'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'sprockets', '< 4.0.0'

# Authentication.
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-google-oauth2'
gem 'omniauth-bn-launcher', '~> 0.1.3'
gem 'net-ldap'
gem 'bn-ldap-authentication', '~> 0.1.4'
gem 'omniauth-bn-office365', '~> 0.1.1'

# BigBlueButton API wrapper.
gem 'bigbluebutton-api-ruby', git: 'https://github.com/mconf/bigbluebutton-api-ruby.git', branch: 'master'

# Front-end.
gem 'bootstrap', '~> 4.3.1'
gem 'tabler-rubygem', git: 'https://github.com/blindsidenetworks/tabler-rubygem.git', tag: '0.1.4.1'
gem 'pagy'
gem 'font-awesome-sass', '~> 5.9.0'

# For detecting the users preferred language.
gem 'http_accept_language'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Markdown parsing.
gem 'redcarpet'

# For limiting access based on user roles
gem 'cancancan', '~> 2.0'

# Active Storage gems
gem 'aws-sdk-s3', '~> 1.75'
gem 'google-cloud-storage', '~> 1.26'

group :production do
  # Use a postgres database in production.
  gem 'pg', '~> 0.18'
  gem 'sequel'

  # For a better logging library in production
  gem "lograge"

  # Use  for the cache store in production
  gem 'redis'
  gem 'hiredis'
end

# Ruby linting.
gem 'rubocop'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  # Environment configuration.
  gem 'dotenv-rails'
  # Use a sqlite database in test and development.
  gem 'sqlite3', '~> 1.3.6'
end

group :test do
  # Include Rspec and other testing utilities.
  gem 'rspec-rails', '~> 3.7'
  gem 'action-cable-testing'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'faker'
  gem "factory_bot_rails"
  gem 'webmock'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'remote_syslog_logger'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data'

gem 'coveralls', require: false

gem 'random_password'

# Adds helpers for the Google reCAPTCHA API
gem "recaptcha"

gem 'i18n-language-mapping', '~> 0.1.1'
