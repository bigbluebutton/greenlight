# frozen_string_literal: true

module Api
  module V1
    class EnvController < ApiController
      def index
        render_json(data: {
                      OPENID_CONNECT: ENV['OPENID_CONNECT_ISSUER'].present?,
                      HCAPTCHA_KEY: ENV.fetch('RECAPTCHA_SITE_KEY', nil)
                    }, status: :ok)
      end
    end
  end
end
