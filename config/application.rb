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
  end
end
