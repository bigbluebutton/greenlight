# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
      missing_params: 'InvalidParams',
      record_not_found: 'RecordNotFound',
      server_error: 'SomethingWentWrong',
      email_exists: 'EmailAlreadyExists',
      record_invalid: 'RecordInvalid',
      invite_token_invalid: 'InviteInvalid',
      hcaptcha_invalid: 'HCaptchaInvalid',
      incorrect_old_password: 'IncorrectOldPassword',
      room_limit: 'RoomLimitError',
      pending_user: 'PendingUser',
      banned_user: 'BannedUser',
      unverified_user: 'UnverifiedUser',
      external_signup_error: 'SignupError',
      unauthorized: 'Unauthorized'
    }

    config.uploads = {
      images: {
        max_size: 3.megabytes,
        formats: %i[png jpg jpeg svg]
      },
      presentations: {
        max_size: 30.megabytes,
        formats: %i[.doc .docx .ppt .pptx .pdf .xls .xlsx .txt .rtf .odt .ods .odp .odg .odc .odi .jpg .jpeg .png]
      }
    }

    ActiveModelSerializers.config.adapter = :json

    config.active_storage.variant_processor = :mini_magick

    # SVGs are served as binary by default, which causes the browser to download the file instead of displaying it
    config.active_storage.content_types_to_serve_as_binary -= ['image/svg+xml']

    config.bigbluebutton_endpoint = ENV.fetch('BIGBLUEBUTTON_ENDPOINT', 'https://test-install.blindsidenetworks.com/bigbluebutton/api')
    config.bigbluebutton_endpoint = File.join(config.bigbluebutton_endpoint, '') unless config.bigbluebutton_endpoint.end_with?('/')
    config.bigbluebutton_endpoint = File.join(config.bigbluebutton_endpoint, '/api/') unless config.bigbluebutton_endpoint.end_with?('api', 'api/')

    config.bigbluebutton_secret = ENV.fetch('BIGBLUEBUTTON_SECRET', '8cd8ef52e8e101574e400365b55e11a6')

    config.voice_bridge_phone_number = ENV.fetch('VOICE_BRIDGE_PHONE_NUMBER', nil)

    config.relative_url_root = ENV.fetch('RELATIVE_URL_ROOT', '/')
    # Fetch 'RELATIVE_URL_ROOT' ENV variable value while removing any trailing slashes.
    config.relative_url_root = ENV.fetch('RELATIVE_URL_ROOT', nil)&.sub(%r{/*\z}, '')
    config.relative_url_root = '/' if config.relative_url_root.blank?

    I18n.load_path += Dir[Rails.root.join('config/locales/*.{rb,yml}').to_s]
  end
end
