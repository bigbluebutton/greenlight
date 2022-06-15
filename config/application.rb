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

    # Reset token max validity period.
    # It's advised to not increase this to more than 15 minutes.
    config.reset_token_validity_period = 15.minutes
  end
end
