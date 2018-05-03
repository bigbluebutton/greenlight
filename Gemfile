source 'https://rubygems.org'

ruby '2.4.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use postgres as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # For environment configuration
  gem 'dotenv-rails'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'mocha'
  gem 'simplecov', :require => false
end

group :production do
  # For more condensed logging
  gem "lograge"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'omniauth', '1.6.1'
gem 'omniauth-twitter', '1.2.1'
gem 'omniauth-google-oauth2', '0.4.1'
gem 'omniauth-ldap'

gem 'bigbluebutton-api-ruby'

gem 'bootstrap-sass', '3.3.0.0'
gem 'bootstrap-social-rails', '~> 4.12'
gem 'font-awesome-sass', '4.7.0'
gem 'jquery-ui-rails'
gem 'jquery-datatables-rails', '~> 3.4.0'
gem 'rails-timeago', '~> 2.0'

gem 'http_accept_language'

# For sending slack notifications.
gem 'slack-notifier'

# For landing background image uploading.
gem 'paperclip', '~> 5.1'

# For uploading recordings to Youtube.
gem 'yt', '~> 0.28.0'

# Simple HTTP client.
gem 'faraday'


# For SAML authentication
gem 'omniauth-saml'

# For device detection to determine BigBlueButton client.
gem 'browser'
