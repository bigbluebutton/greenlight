# frozen_string_literal: true

module Api
  module V1
    class EnvController < ApiController
      def index
        render_data data: {
          OPENID_CONNECT: ENV['OPENID_CONNECT_ISSUER'].present?,
          HCAPTCHA_KEY: ENV.fetch('RECAPTCHA_SITE_KEY', nil),
          VERSION_TAG: ENV.fetch('VERSION_TAG', '')
        }, status: :ok
      end
    end
  end
end
