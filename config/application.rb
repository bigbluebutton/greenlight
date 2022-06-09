# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Greenlight
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Custom error messages for the Client side.
    config.custom_error_msgs = {
      # TODO: amir - Add I18n.
      missing_params: 'Invalid or Missing parameters.',
      record_not_found: 'Record Not Found',
      server_error: 'Something Went Wrong'
    }

    # This hash will hold the supported available locales and their native name.
    # I18n_data gem can be used https://github.com/grosser/i18n_data
    config.available_locales_hash = {
      en: 'English',
      ar: 'العربيّة',
      fr: 'Français',
      es: 'Española'
    }

    I18n.default_locale = :en # TODO: Enable administrators to inject this config.
    I18n.available_locales = config.available_locales_hash.keys # TODO: Enable administrators to inject this config.
  end
end
