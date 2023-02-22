# frozen_string_literal: true

module Api
  module V1
    class VerifyAccountController < ApiController
      include ClientRoutable

      skip_before_action :ensure_authenticated, only: %i[create activate]
      before_action :find_user_and_authorize, only: :create

      # POST /api/v1/verify_account.json
      # Creates a unique token, saves its digest to the user and emails it
      def create
        token = @user.generate_activation_token!

        UserMailer.with(user: @user,
                        activation_url: activate_account_url(token), base_url: request.base_url,
                        provider: current_provider).activate_account_email.deliver_later

        render_data status: :ok
      end

      # POST /api/v1/verify_account/activate.json
      # Validates the token and activates the account
      def activate
        return render_error status: :bad_request if params[:user].blank?

        token = params[:user][:token]

        return render_error status: :bad_request if token.blank?

        user = User.verify_activation_token(token)
        return render_error status: :forbidden unless user

        # TODO: Amir - optimise this.
        return render_error status: :internal_server_error unless user.invalidate_activation_token

        user.verify!

        render_data status: :ok
      end

      private

      def find_user_and_authorize
        return render_error status: :bad_request unless params[:user]

        @user = User.find_by id: params[:user][:id]
        return render_data status: :ok unless @user && !@user.verified?
      end
    end
  end
end
