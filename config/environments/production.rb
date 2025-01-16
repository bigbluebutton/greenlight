# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"], config/master.key, or an environment
  # key such as config/credentials/production.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from `public/`, relying on NGINX/Apache to do so instead.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fall back to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = if ENV['S3_ACCESS_KEY_ID'].present? && ENV['S3_ENDPOINT'].present?
                                    :s3
                                  elsif ENV['S3_ACCESS_KEY_ID'].present?
                                    :amazon
                                  elsif ENV['GCS_PROJECT'].present?
                                    :google
                                  else
                                    :local
                                  end

  if ENV['SMTP_SERVER'].present?
    config.action_mailer.perform_deliveries = true
    config.action_mailer.delivery_method = :smtp

    smtp_settings = {
      address: ENV.fetch('SMTP_SERVER'),
      port: ENV.fetch('SMTP_PORT'),
      domain: ENV.fetch('SMTP_DOMAIN'),
      user_name: ENV.fetch('SMTP_USERNAME', nil),
      password: ENV.fetch('SMTP_PASSWORD', nil),
      authentication: ENV.fetch('SMTP_AUTH', nil),
      enable_starttls_auto: ActiveModel::Type::Boolean.new.cast(ENV.fetch('SMTP_STARTTLS_AUTO', nil)),
      enable_starttls: ActiveModel::Type::Boolean.new.cast(ENV.fetch('SMTP_STARTTLS', nil)),
      tls: ActiveModel::Type::Boolean.new.cast(ENV.fetch('SMTP_TLS', nil)),
      openssl_verify_mode: ENV.fetch('SMTP_SSL_VERIFY', 'true') == 'false' ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
    }.compact

    config.action_mailer.smtp_settings = smtp_settings
    config.action_mailer.default_options = {
      from: ActionMailer::Base.email_address_with_name(ENV.fetch('SMTP_SENDER_EMAIL'), ENV.fetch('SMTP_SENDER_NAME', nil))
    }
  else
    config.action_mailer.perform_deliveries = false
  end

  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  config.action_mailer.raise_delivery_errors = true
  # Disable caching for Action Mailer templates even if Action Controller
  # caching is enabled.
  config.action_mailer.perform_caching = false
  config.action_mailer.deliver_later_queue_name = 'mailing'

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # "info" includes generic and useful information about system operation, but avoids logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII). If you
  # want to log everything, set the level to "debug".
  config.log_level = ENV.fetch('LOG_LEVEL', 'info')

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new "app-name")

  if ENV['RAILS_LOG_REMOTE_NAME'] && ENV['RAILS_LOG_REMOTE_PORT']
    require 'remote_syslog_logger'
    logger_program = ENV['RAILS_LOG_REMOTE_TAG'] || "greenlight-v3-#{ENV.fetch('RAILS_ENV', nil)}"
    logger = RemoteSyslogLogger.new(ENV['RAILS_LOG_REMOTE_NAME'], ENV['RAILS_LOG_REMOTE_PORT'], program: logger_program)
  else
    $stdout.sync = true
    logger = ActiveSupport::Logger.new($stdout)
  end

  logger.formatter = config.log_formatter
  config.logger = ActiveSupport::TaggedLogging.new(logger)

  # Use Lograge for logging
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    { time: Time.zone.now, host: event.payload[:host] }
  end

  config.lograge.ignore_actions = ['HealthChecksController#check',
                                   'ApplicationCable::Connection#connect', 'RoomsChannel#subscribe',
                                   'ApplicationCable::Connection#disconnect', 'RoomsChannel#unsubscribe']

  # Use a different cache store in production.
  config.cache_store = :redis_cache_store, { url: ENV.fetch('REDIS_URL', nil) }

  # Use a real queuing backend for Active Job (and separate queues per environment).
  config.active_job.queue_adapter = :async # TODO: Configure :resque
  config.active_job.queue_name_prefix = 'greenlight_v3_production'

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # Can be used together with config.force_ssl for Strict-Transport-Security and secure cookies.
  # config.assume_ssl = true

  # Enable HSTS in production mode
  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true
  config.ssl_options = {
    redirect: { exclude: ->(request) { request.path.include?('health_check') } },
    hsts: { expires: 1.year, subdomains: true }
  }

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [:id]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  # Skip DNS rebinding protection for the default health check endpoint.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
