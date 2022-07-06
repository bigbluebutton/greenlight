# frozen_string_literal: true

module Api
  module V1
    class VerifyAccountController < ApiController
      

      # POST /api/v1/verify_account.json
      # Expects: { user: {:email} }
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Creates a unique token, saves its digest and emails it.

      def create
        # TODO: Log events.
        return render_error status: :bad_request unless params[:user]

        user = User.find_by email: params[:user][:email]

        # Silentley fail for invalid emails or already active users.
        return render_data unless user && !user.active?

        token = user.generate_activation_token!

        render_json data: { token: } # TODO: enable activation email sending.
      end

      # POST /api/v1/verify_account/activate.json
      # Expects: { user: {:token} }
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Validates the token and activates the account.

      def activate
        return render_error status: :bad_request if params[:user].blank?

        token = params[:user][:token]

        return render_error status: :bad_request if token.blank?

        user = User.verify_activation_token(token)
        return render_error status: :forbidden unless user

        # TODO: optimise this.
        return render_error status: :internal_server_error unless user.invalidate_activation_token

        user.activate!

        render_data
      end
    end
  end
end
