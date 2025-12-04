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

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing.
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = if ENV['AS_MIRROR_PRIMARY'].present?
                                    :mirror
                                  elsif ENV['S3_ACCESS_KEY_ID'].present? && ENV['S3_ENDPOINT'].present?
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

  config.action_mailer.raise_delivery_errors = true
  # Disable caching for Action Mailer templates even if Action Controller
  # caching is enabled.
  config.action_mailer.perform_caching = false

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  config.hosts = nil
end
