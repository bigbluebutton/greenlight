# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

if Rails.configuration.loadbalanced_configuration
    Rails.application.config.session_store :cookie_store, key: '_greenlight-2_0_session',
        domain: ENV['GREENLIGHT_SESSION_DOMAIN'] || 'blindside-dev.com'
else
    Rails.application.config.session_store :cookie_store, key: '_greenlight-2_0_session'
end
