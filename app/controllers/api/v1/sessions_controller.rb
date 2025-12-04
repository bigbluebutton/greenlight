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
      before_action :ensure_unauthenticated, only: :create

      # GET /api/v1/sessions
      # Returns the current_user
      def index
        return render_data data: current_user, serializer: CurrentUserSerializer, status: :ok if current_user

        render_data data: { signed_in: false, default_locale: ENV.fetch('DEFAULT_LOCALE', nil) }, status: :ok
      end

      # POST /api/v1/sessions
      # Signs a user in and updates the session cookie
      def create
        if hcaptcha_enabled? && !verify_hcaptcha(response: params[:token])
          return render_error errors: Rails.configuration.custom_error_msgs[:hcaptcha_invalid]
        end

        # Search for a user within the current provider and, if not found, search for a super admin within bn provider
        user = User.find_by(email: session_params[:email].downcase, provider: current_provider) ||
               User.find_by(email: session_params[:email].downcase, provider: 'bn')

        # Return an error if the user is not found
        return render_error if user.blank?

        # Will return an error if the user is NOT from the current provider and if the user is NOT a super admin
        return render_error status: :forbidden if !user.super_admin? && (user.provider != current_provider || external_auth?)

        # Password is not set (local user migrated from v2)
        if user.external_id.blank? && user.password_digest.blank?
          token = user.generate_reset_token!
          return render_error data: token, errors: 'PasswordNotSet'
        end

        if user.authenticate(session_params[:password])
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
        id_token = session.delete(:oidc_id_token)
        logout_path = ENV.fetch('OPENID_CONNECT_LOGOUT_PATH', '')

        # Make logout request to OIDC
        if logout_path.present? && id_token.present? && external_auth?
          issuer_url = if ENV.fetch('LOADBALANCER_ENDPOINT', nil).present?
                         File.join(ENV.fetch('OPENID_CONNECT_ISSUER'), "/#{current_provider}")
                       else
                         ENV.fetch('OPENID_CONNECT_ISSUER')
                       end

          end_session = File.join(issuer_url, logout_path)

          url = "#{end_session}?client_id=#{ENV.fetch('OPENID_CONNECT_CLIENT_ID', nil)}" \
                "&id_token_hint=#{id_token}" \
                "&post_logout_redirect_uri=#{CGI.escape(root_url(success: 'LogoutSuccessful'))}"

          sign_out
          render_data data: url, status: :ok
        else
          sign_out
          render_data status: :ok
        end
      end

      private

      def session_params
        params.require(:session).permit(:email, :password, :extend_session)
      end

      def sign_in(user)
        user.generate_session_token!(extended_session: session_params[:extend_session])
        user.update(last_login: DateTime.now)

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
