# frozen_string_literal: true

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

    # Use custom error routes.
    config.exceptions_app = routes

    config.loadbalanced_configuration = ENV["LOADBALANCER_ENDPOINT"].present? && ENV["LOADBALANCER_SECRET"].present?


    # Default credentials (test-install.blindsidenetworks.com/bigbluebutton).
    config.bigbluebutton_endpoint_default = "http://test-install.blindsidenetworks.com/bigbluebutton/api"
    config.bigbluebutton_secret_default = "8cd8ef52e8e101574e400365b55e11a6"


    # Fetch credentials from a loadbalancer based on provider.
    config.loadbalancer_endpoint = ENV["LOADBALANCER_ENDPOINT"]
    config.loadbalancer_secret = ENV["LOADBALANCER_SECRET"]

    # Use standalone BigBlueButton server.
    config.bigbluebutton_endpoint = ENV["BIGBLUEBUTTON_ENDPOINT"] || config.bigbluebutton_endpoint_default
    config.bigbluebutton_endpoint += "api" unless config.bigbluebutton_endpoint.ends_with?('api')
    config.bigbluebutton_secret = ENV["BIGBLUEBUTTON_SECRET"] || config.bigbluebutton_secret_default

    # Determine if GreenLight should allow non-omniauth signup/login.
    config.allow_user_signup = (ENV['ALLOW_GREENLIGHT_ACCOUNTS'] == "true")

    # Configure custom banner message.
    config.banner_message = ENV['BANNER_MESSAGE']
  end
end
