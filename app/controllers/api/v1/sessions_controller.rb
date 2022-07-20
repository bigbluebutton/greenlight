# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ApiController
      # GET /api/v1/sessions
      def index
        return render_data data: current_user, serializer: CurrentUserSerializer, status: :ok if current_user

        render_data data: { signed_in: false }, status: :ok
      end

      # POST /api/v1/sessions
      def create
        user = User.find_by(email: session_params[:email])

        # TODO: Add proper error logging for non-verified token hcaptcha
        return render_error if hcaptcha_enabled? && !verify_hcaptcha(response: params[:token])

        # TODO: Add proper error logging for non-verified token hcaptcha
        if user.present? && user.authenticate(session_params[:password])
          sign_in user
          render_data data: current_user, serializer: CurrentUserSerializer, status: :ok
        else
          render_error
        end
      end

      # DELETE /api/v1/sessions/signout
      def destroy
        sign_out
        render_data status: :ok
      end

      private

      def session_params
        params.require(:session).permit(:email, :password, :extend_session)
      end

      def sign_in(user)
        # Creates an extended_session cookie instead of a session cookie if extend_session is selected in sign in form.
        if session_params[:extend_session]
          cookies.encrypted[:_extended_session] = {
            value: {
              user_id: user.id
            },
            expires: 7.days,
            httponly: true
          }
        else
          session[:user_id] = user.id
        end
      end

      def sign_out
        reset_session
        cookies.delete :_extended_session
      end
    end
  end
end
