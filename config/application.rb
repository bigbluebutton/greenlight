# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2016 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Greenlight
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # i18n
    # ensure each language has a regional fallback
    config.i18n.available_locales = %w(en en-US)
    config.i18n.default_locale = 'en-US'
    config.i18n.fallbacks = {'en' => 'en-US'}

    # BigBlueButton
    config.bigbluebutton_endpoint = ENV['BIGBLUEBUTTON_ENDPOINT']
    config.bigbluebutton_secret = ENV['BIGBLUEBUTTON_SECRET']

    config.use_webhooks = ENV['GREENLIGHT_USE_WEBHOOKS'] == "true"
    config.mail_notifications = ENV['GREENLIGHT_MAIL_NOTIFICATIONS'] == "true"

    # SMTP and action mailer
    if config.mail_notifications
      config.smtp_from = ENV['SMTP_FROM']
      config.smtp_server = ENV['SMTP_SERVER']
      config.smtp_domain = ENV['SMTP_DOMAIN']
      config.smtp_port = ENV['SMTP_PORT'] || 587
      config.smtp_username = ENV['SMTP_USERNAME']
      config.smtp_password = ENV['SMTP_PASSWORD']
      config.smtp_auth = ENV['SMTP_AUTH'] || "login"
      config.smtp_starttls_auto = ENV['SMTP_STARTTLS_AUTO'].nil? ? true : ENV['SMTP_STARTTLS_AUTO']
      config.smtp_tls = ENV['SMTP_TLS'].nil? ? false : ENV['SMTP_TLS']

      config.action_mailer.default_url_options = { host: ENV['GREENLIGHT_DOMAIN'] }
      config.action_mailer.delivery_method = :smtp
      config.action_mailer.perform_deliveries = true
      config.action_mailer.raise_delivery_errors = true
      config.action_mailer.smtp_settings = {
        address:              config.smtp_server,
        domain:               config.smtp_domain,
        port:                 config.smtp_port,
        user_name:            config.smtp_username,
        password:             config.smtp_password,
        authentication:       config.smtp_auth,
        enable_starttls_auto: config.smtp_starttls_auto,
        tls:                  config.smtp_tls
      }
      config.action_mailer.default_options = {
        from: config.smtp_from
      }
    else
      # this needs to be set because it's always used to configure mailers
      config.smtp_from = ""
    end
  end
end
