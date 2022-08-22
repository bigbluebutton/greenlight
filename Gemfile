# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'aws-sdk-s3', '~> 1.88.1'
gem 'bcrypt', '~> 3.1.7'
gem 'bigbluebutton-api-ruby', '~> 1.9'
gem 'bn-ldap-authentication', '~> 0.1.4'
gem 'bootsnap', '~> 1.7.2', require: false
gem 'bootstrap', '~> 4.3.1'
gem 'cancancan', '~> 2.3.0'
gem 'coveralls', '~> 0.8.23', require: false
gem 'font-awesome-sass', '~> 5.9.0'
gem 'google-cloud-storage', '~> 1.30.0'
gem 'http_accept_language', '~> 2.1.1'
gem 'i18n-language-mapping', '~> 0.1.3.1'
gem 'jbuilder', '~> 2.11.5'
gem 'jquery-rails', '~> 4.4.0'
gem 'local_time', '~> 2.1.0'
gem 'net-ldap', '~> 0.17.0'
gem 'omniauth', '~> 2.1.0'
gem 'omniauth-bn-launcher', '~> 0.1.5'
gem 'omniauth-bn-office365', '~> 0.1.2'
gem 'omniauth-google-oauth2', '~> 1.0.1'
gem 'omniauth_openid_connect', '~> 0.4.0'
gem 'omniauth-rails_csrf_protection', '~> 1.0.1'
gem 'omniauth-twitter', '~> 1.4.0'
gem 'pagy', '~> 3.11.0'
gem 'pluck_to_hash', '~> 1.0.2'
gem 'puma', '~> 4.3.12'
gem 'rails', '~> 5.2.8.1'
gem 'random_password', '~> 0.1.1'
gem "recaptcha", '~> 5.7.0'
gem 'redcarpet', '~> 3.5.1'
gem 'remote_syslog_logger', '~> 1.0.4'
gem 'repost', '~> 0.3.8'
gem 'rubocop', '~> 1.10.0'
gem 'sassc-rails', '~> 2.1.2'
gem 'sprockets', '~> 3.7.2'
gem 'sqlite3', '~> 1.3.6'
gem 'tabler-rubygem', git: 'https://github.com/blindsidenetworks/tabler-rubygem.git', tag: '0.1.4.1'
gem 'turbolinks', '~> 5.2.1'
gem 'tzinfo-data', '~> 1.2021.5'
gem 'uglifier', '~> 4.2.0'

group :production do
  gem 'hiredis', '~> 0.6.3'
  gem "lograge", "~> 0.11.2"
  gem 'pg', '~> 0.18'
  gem 'redis', '~> 4.2.5'
  gem 'sequel', '~> 5.41.0'
end

group :development, :test do
  gem 'byebug', '~> 11.1', platform: :mri
  gem 'dotenv-rails', '~> 2.7', '>= 2.7.6'
end

group :test do
  gem 'action-cable-testing', '~> 0.6', '>= 0.6.1'
  gem "factory_bot_rails", "~> 6.2", ">= 6.2.0"
  gem 'faker', '~> 2.16'
  gem 'rails-controller-testing', '~> 1.0', '>= 1.0.5'
  gem 'rspec-rails', '~> 3.9', '>= 3.9.1'
  gem 'shoulda-matchers', '~> 3.1', '>= 3.1.3'
  gem 'webmock', '~> 3.11'
end

group :development do
  gem 'listen', '~> 3.0'
  gem 'spring', '~> 2.1'
  gem 'spring-watcher-listen', '~> 2.0'
  gem 'web-console', '~> 3.7', '>= 3.7.0'
end
