# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  if ENV['REDIS_URL'].present?
    # Set up Redis cache store
    config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'],

      connect_timeout:    30,  # Defaults to 20 seconds
      read_timeout:       0.2, # Defaults to 1 second
      write_timeout:      0.2, # Defaults to 1 second
      reconnect_attempts: 1,   # Defaults to 0

      error_handler: lambda { |method:, returning:, exception:|
        config.logger.warn "Support: Redis cache action #{method} failed and returned '#{returning}': #{exception}"
      } }
  else
    config.cache_store = :memory_store
  end

  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.years.to_i}"
  }

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].blank?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = Uglifier.new(harmony: true)
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = if ENV["AWS_ACCESS_KEY_ID"].present?
                                    :amazon
                                  elsif ENV["S3_ACCESS_KEY_ID"].present?
                                    :s3
                                  elsif ENV["GCS_PRIVATE_KEY_ID"].present?
                                    :google
                                  else
                                    :local
                                  end

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = (ENV["ENABLE_SSL"] == "true")

  # Don't wrap form components in field_with_error divs
  ActionView::Base.field_error_proc = proc do |html_tag|
    html_tag.html_safe
  end

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Tell Action Mailer to use smtp server, if configured
  config.action_mailer.delivery_method = ENV['SMTP_SERVER'].present? ? :smtp : :sendmail

  ActionMailer::Base.smtp_settings = if ENV['SMTP_AUTH'].present? && ENV['SMTP_AUTH'] != "none"
    {
      address: ENV['SMTP_SERVER'],
      port: ENV["SMTP_PORT"],
      domain: ENV['SMTP_DOMAIN'],
      user_name: ENV['SMTP_USERNAME'],
      password: ENV['SMTP_PASSWORD'],
      authentication: ENV['SMTP_AUTH'],
      enable_starttls_auto: ENV['SMTP_STARTTLS_AUTO'],
    }
  else
    {
      address: ENV['SMTP_SERVER'],
      port: ENV["SMTP_PORT"],
      domain: ENV['SMTP_DOMAIN'],
      enable_starttls_auto: ENV['SMTP_STARTTLS_AUTO'],
    }
  end

  # enable SMTPS: SMTP over direct TLS connection
  ActionMailer::Base.smtp_settings[:tls] = true if ENV['SMTP_TLS'].present? && ENV['SMTP_TLS'] != "false"

  # If configured to 'none' don't check the smtp servers certificate
  ActionMailer::Base.smtp_settings[:openssl_verify_mode] =
    ENV['SMTP_OPENSSL_VERIFY_MODE'] if ENV['SMTP_OPENSSL_VERIFY_MODE'].present?

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "greenlight-2_0_#{Rails.env}"
  config.action_mailer.perform_caching = false

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Specify the log level
  config.log_level = ENV["RAILS_LOG_LEVEL"].present? ? ENV['RAILS_LOG_LEVEL'].to_sym : :info

  # Use Lograge for logging
  config.lograge.enabled = true

  config.lograge.ignore_actions = ["HealthCheckController#all", "ThemesController#index",
                                   "ApplicationCable::Connection#connect", "WaitingChannel#subscribe",
                                   "ApplicationCable::Connection#disconnect", "WaitingChannel#unsubscribe"]

  config.lograge.custom_options = lambda do |event|
    # capture some specific timing values you are interested in
    { host: event.payload[:host] }
  end

  config.log_formatter = proc do |severity, time, _progname, msg|
    "#{time} - #{severity}: #{msg} \n"
  end

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id, :remote_ip]

  if ENV["RAILS_LOG_TO_STDOUT"] == "true"
    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  elsif ENV["RAILS_LOG_REMOTE_NAME"] && ENV["RAILS_LOG_REMOTE_PORT"]
    require 'remote_syslog_logger'
    logger_program = ENV["RAILS_LOG_REMOTE_TAG"] || "greenlight-#{ENV['RAILS_ENV']}"
    logger = RemoteSyslogLogger.new(ENV["RAILS_LOG_REMOTE_NAME"],
      ENV["RAILS_LOG_REMOTE_PORT"], program: logger_program)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Set the relative url root for deployment to a subdirectory.
  config.relative_url_root = ENV['RELATIVE_URL_ROOT'] || "/b" if ENV['RELATIVE_URL_ROOT'] != "/"

  config.hosts = ENV['SAFE_HOSTS'].presence || nil
end
