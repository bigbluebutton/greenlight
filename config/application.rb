require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Greenlight20
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Use custom error routes.
    config.exceptions_app = self.routes

    config.loadbalanced_configuration = (ENV["USE_LOADBALANCED_CONFIGURATION"] == "true")

    # Setup BigBlueButton configuration.
    unless config.loadbalanced_configuration
      # Default credentials (test-install.blindsidenetworks.com/bigbluebutton).
      config.bigbluebutton_endpoint_default = "http://test-install.blindsidenetworks.com/bigbluebutton/api/"
      config.bigbluebutton_secret_default = "8cd8ef52e8e101574e400365b55e11a6"

      # Use standalone BigBlueButton server.
      config.bigbluebutton_endpoint = ENV["BIGBLUEBUTTON_ENDPOINT"]
      config.bigbluebutton_secret = ENV["BIGBLUEBUTTON_SECRET"]

      # Fallback to testing credentails.
      if config.bigbluebutton_endpoint.blank?
        config.bigbluebutton_endpoint = config.bigbluebutton_endpoint_default
        config.bigbluebutton_secret = config.bigbluebutton_secret_default
      end

      # Fix endpoint format if required.
      config.bigbluebutton_endpoint += "api/" unless config.bigbluebutton_endpoint.ends_with?('api/')
    else
      # Fetch credentials from a loadbalancer based on provider.
      config.loadbalancer_endpoint = ENV["LOADBALANCER_ENDPOINT"]
      config.loadbalancer_secret = ENV["LOADBALANCER_SECRET"]
    end

    # Determine if GreenLight should allow non-omniauth signup/login.
    config.allow_user_signup = (ENV['ALLOW_GREENLIGHT_ACCOUNTS'] == "true")
  end
end
