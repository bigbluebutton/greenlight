# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.7'

# Use Puma as the app server
gem 'puma', '~> 3.0'

# Use SQLite as the primary database.
gem 'sqlite3', '~> 1.3'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'mini_racer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Authentication.
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-google-oauth2'
gem 'omniauth-microsoft-office365', '~> 0.0.7'
gem 'omniauth-ldap'
gem 'omniauth-bn-launcher', '~> 0.1.0'

# BigBlueButton API wrapper.
gem 'bigbluebutton-api-ruby'

# Front-end.
gem 'bootstrap', '~> 4.3.1'
gem 'tabler-rubygem'
gem 'pagy'

# For detecting the users preferred language.
gem 'http_accept_language'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Markdown parsing.
gem 'redcarpet'

# For health check endpoint
gem "health_check"

# For providing user roles
gem "rolify"
# For limiting access based on user roles
gem 'cancancan', '~> 2.0'

group :production do
  # Use a postgres database in production.
  gem 'pg', '~> 0.18'
end

# Ruby linting.
gem 'rubocop'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  # Environment configuration.
  gem 'dotenv-rails'
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
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'coveralls', require: false

gem 'random_password'

# Adds helpers for the Google reCAPTCHA API
gem "recaptcha"
