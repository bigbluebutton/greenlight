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

    # Custom response msgs for the Client side.
    config.response_msgs = {
      success: 'success', # TODO: amir - Add I18n.
      failed: 'failed' # TODO: amir - Add I18n.
    }
    config.custom_error_msgs = {
      missing_params: 'Invalid or Missing parameters.' # TODO: amir - Add I18n.
    }
  end
end
