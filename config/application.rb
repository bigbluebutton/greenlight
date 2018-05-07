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

    # Default credentials (test-install.blindsidenetworks.com/bigbluebutton).
    config.bigbluebutton_endpoint_default = 'http://test-install.blindsidenetworks.com/bigbluebutton/'
    config.bigbluebutton_secret_default = '8cd8ef52e8e101574e400365b55e11a6'

    # BigBlueButton configuration.
    config.bigbluebutton_endpoint = ENV['BIGBLUEBUTTON_ENDPOINT']  || config.bigbluebutton_endpoint_default
    config.bigbluebutton_secret = ENV['BIGBLUEBUTTON_SECRET'] || config.bigbluebutton_secret_default
  end
end
