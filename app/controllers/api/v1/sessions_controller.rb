# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ApiController
      # GET /api/v1/sessions
      def index
        return render_data data: current_user, serializer: CurrentUserSerializer if current_user

        render_data data: { signed_in: false }
      end

      # POST /api/v1/sessions
      def create
        user = User.find_by(email: session_params[:email])

        # TODO: Add proper error logging for non-verified token hcaptcha
        return render_error if hcaptcha_enabled? && !verify_hcaptcha(response: params[:token])

        # TODO: Add proper error logging for non-verified token hcaptcha
        if user.present? && user.authenticate(session_params[:password])
          remember user if session_params[:remember_me]
          sign_in user
          render_data data: current_user, serializer: CurrentUserSerializer
        else
          render_error
        end
      end

      # DELETE /api/v1/sessions/signout
      def destroy
        session[:user_id] = nil
        render_data
      end

      private

      def session_params
        params.require(:session).permit(:email, :password, :remember_me)
      end

      # Signs In the user
      def sign_in(user)
        session[:user_id] = user.id
      end

      def remember(user)
        cookie.permanent.signed[:user_id] = user.id
        cookie.permanent[:remember_token] = user.generate_remember_token!
      end
    end
  end
end
