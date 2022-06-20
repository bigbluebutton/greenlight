# frozen_string_literal: true

module Api
  module V1
    class VerifyAccountController < ApiController
      skip_before_action :verify_authenticity_token

      # POST /api/v1/verify_account.json
      # Expects: { user: {:email} }
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Creates a unique token, saves its digest and emails it.

      def create
        # TODO: Log events.
        return render_json status: :bad_request unless params[:user]

        user = User.find_by email: params[:user][:email]

        # Silentley fail for invalid emails or already active users.
        return render_json unless user && !user.active?

        token = user.generate_activation_token!

        render_json data: { token: } # TODO: enable activation email sending.
      end
    end
  end
end
