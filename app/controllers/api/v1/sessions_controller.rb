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
        logout_url = oidc_logout_url(logout_path, id_token) if logout_path.present? && id_token.present? && external_auth?

        sign_out

        return render_data data: logout_url, status: :ok if logout_url.present?

        render_data status: :ok
      end

      private

      def session_params
        params.expect(session: %i[email password extend_session])
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

      # Returns the RP-initiated logout URL of the OIDC provider, or nil if it can't be determined
      def oidc_logout_url(logout_path, id_token)
        end_session = oidc_end_session_endpoint(logout_path)
        return if end_session.blank?

        query = URI.encode_www_form(
          client_id: ENV.fetch('OPENID_CONNECT_CLIENT_ID', ''),
          id_token_hint: id_token,
          post_logout_redirect_uri: root_url(success: 'LogoutSuccessful')
        )

        "#{end_session}#{end_session.include?('?') ? '&' : '?'}#{query}"
      end

      # OPENID_CONNECT_LOGOUT_PATH is either an absolute URL (used as-is, e.g. if the end session endpoint
      # is served from a different host than the issuer), 'discovery' (use the end_session_endpoint from the
      # provider's discovery document) or a path relative to the issuer
      def oidc_end_session_endpoint(logout_path)
        return logout_path if logout_path.match?(%r{\Ahttps?://}i)
        return discovered_end_session_endpoint(oidc_issuer_url) if logout_path == 'discovery'

        File.join(oidc_issuer_url, logout_path)
      end

      # Not cached: sign out is rare and the login flow already fetches the discovery document on every login
      def discovered_end_session_endpoint(issuer)
        OpenIDConnect::Discovery::Provider::Config.discover!(issuer).end_session_endpoint
      rescue StandardError => e
        Rails.logger.error("Failed to discover the OIDC end session endpoint: #{e}")
        nil
      end

      def oidc_issuer_url
        return File.join(ENV.fetch('OPENID_CONNECT_ISSUER'), "/#{current_provider}") if ENV.fetch('LOADBALANCER_ENDPOINT', nil).present?

        ENV.fetch('OPENID_CONNECT_ISSUER')
      end
    end
  end
end
