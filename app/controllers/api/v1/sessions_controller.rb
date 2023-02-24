# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ApiController
      skip_before_action :ensure_authenticated, only: %i[index create]

      # GET /api/v1/sessions
      # Returns the current_user
      def index
        return render_data data: current_user, serializer: CurrentUserSerializer, status: :ok if current_user

        render_data data: { signed_in: false }, status: :ok
      end

      # POST /api/v1/sessions
      # Signs a user in and updates the session cookie
      def create
        user = User.find_by(email: session_params[:email])

        # TODO: Add proper error logging for non-verified token hcaptcha
        return render_error if hcaptcha_enabled? && !verify_hcaptcha(response: params[:token])

        # TODO: Add proper error logging for non-verified token hcaptcha
        if user.present? && user.authenticate(session_params[:password])
          return render_error data: user.id, errors: Rails.configuration.custom_error_msgs[:unverified_user] unless user.verified?
          return render_error errors: Rails.configuration.custom_error_msgs[:pending_user] if user.pending?
          return render_error errors: Rails.configuration.custom_error_msgs[:banned_user] if user.banned?

          sign_in user
          render_data data: current_user, serializer: CurrentUserSerializer, status: :ok
        else
          render_error
        end
      end

      # DELETE /api/v1/sessions/signout
      # Clears the session cookie and signs the user out
      def destroy
        sign_out
        render_data status: :ok
      end

      private

      def session_params
        params.require(:session).permit(:email, :password, :extend_session)
      end

      def sign_in(user)
        user.generate_session_token!(extended_session: session_params[:extend_session])

        # Creates an extended_session cookie if extend_session is selected in sign in form.
        if session_params[:extend_session]
          cookies.encrypted[:_extended_session] = {
            value: {
              session_token: user.session_token
            },
            expires: 7.days,
            httponly: true,
            secure: true
          }
        end

        session[:session_token] = user.session_token
      end

      def sign_out
        current_user.generate_session_token!
        session[:session_token] = nil
        cookies.delete :_extended_session
      end
    end
  end
end
