# frozen_string_literal: true

module Api
  module V1
    class ResetPasswordController < ApiController
      before_action :verify_reset_request, only: %i[reset verify]
      skip_before_action :ensure_authenticated, only: %i[create reset verify]

      # POST /api/v1/reset_password.json
      # Expects: { user: {:email} }
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Creates a unique token, saves its digest and emails it.

      def create
        # TODO: Log events.
        return render_error unless params[:user]

        user = User.find_by email: params[:user][:email]

        # Silently fail for unfound or external users.
        return render_data status: :ok unless user && !user.external_id?

        token = user.generate_reset_token!

        UserMailer.with(user:, expires_in: User::RESET_TOKEN_VALIDITY_PERIOD.from_now,
                        reset_url: reset_password_url(token)).reset_password_email.deliver_later

        render_data status: :ok
      end

      # POST /api/v1/reset_password/reset.json
      # Expects: { user: {:token, :new_password} }
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Validates the token and reset the user password.

      def reset
        new_password = params[:user][:new_password]

        return render_error status: :bad_request if new_password.blank?

        # Invalidating token and changing the password.
        # TODO: optimise this.
        return render_error status: :internal_server_error unless @user.invalidate_reset_token

        @user.update! password: new_password

        render_data status: :ok
      end

      # POST /api/v1/reset_password/verify.json
      # Expects: { user: {:token} }
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Validates the token.

      def verify
        render_data status: :ok
      end

      private

      def verify_reset_request
        return render_error status: :bad_request if params[:user].blank?

        token = params[:user][:token]

        return render_error status: :bad_request if token.blank?

        @user = User.verify_reset_token(token)
        render_error status: :forbidden unless @user
      end

      def reset_password_url(token)
        "#{root_url}reset_password/#{token}" # Client side reset password url.
      end
    end
  end
end
