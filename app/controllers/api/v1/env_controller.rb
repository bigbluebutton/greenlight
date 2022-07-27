# frozen_string_literal: true

module Api
  module V1
    class EnvController < ApiController
      skip_before_action :ensure_authenticated

      def index
        render_data data: {
          OPENID_CONNECT: ENV['OPENID_CONNECT_ISSUER'].present?,
          HCAPTCHA_KEY: ENV.fetch('HCAPTCHA_SITE_KEY', nil),
          VERSION_TAG: ENV.fetch('VERSION_TAG', '')
        }, status: :ok
      end
    end
  end
end
