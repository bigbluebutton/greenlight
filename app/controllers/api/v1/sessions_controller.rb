# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ApiController
      # TODO: samuel - Bypass CSRF token for now
      skip_before_action :verify_authenticity_token

      include Avatarable

      # GET /api/v1/sessions
      def index
        if current_user
          render_json data: {
            current_user: {
              id: current_user.id,
              name: current_user.name,
              email: current_user.email,
              provider: current_user.provider,
              avatar: user_avatar(current_user),
              signed_in: true,
              language: current_user.language,
              active: current_user.active
            }
          }
        else
          render_json data: { signed_in: false }
        end
      end

      # POST /api/v1/sessions
      def create
        user = User.find_by(email: session_params[:email])

        # TODO: Add proper error logging for non-verified token hcaptcha
        return render json: { signed_in: false }, status: :bad_request if hcaptcha_enabled? && !verify_hcaptcha(response: params[:token])

        # TODO: Add proper error logging for non-verified token hcaptcha
        if user.present? && user.authenticate(session_params[:password])
          sign_in user
          render json: { current_user:, signed_in: true }, status: :ok
        else
          render json: { signed_in: false }, status: :bad_request
        end
      end

      # DELETE /api/v1/sessions/signout
      def destroy
        session[:user_id] = nil
        render json: { signed_in: false }, status: :ok
      end

      private

      def session_params
        params.require(:session).permit(:email, :password)
      end

      # Signs In the user
      def sign_in(user)
        session[:user_id] = user.id
      end
    end
  end
end
