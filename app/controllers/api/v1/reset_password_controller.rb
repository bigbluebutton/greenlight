# frozen_string_literal: true

module Api
  module V1
    class ResetPasswordController < ApiController
      skip_before_action :verify_authenticity_token

      # POST /api/v1/reset_password.json
      # Expects: { user: {:email} }
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Creates a unique token, saves its digest and emails it.

      def create
        # TODO: Log events.
        return render_json status: :bad_request unless params[:user]

        user = User.find_by email: params[:user][:email]

        # Silently fail for unfound or external users.
        return render_json unless user && !user.external_id?

        token = user.generate_reset_token!

        render_json data: { token: } # TODO: enable reset email sending.
      end
    end
  end
end
