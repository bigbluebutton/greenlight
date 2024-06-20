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
    class ResetPasswordController < ApiController
      include ClientRoutable

      before_action :verify_reset_request, only: %i[reset verify]
      skip_before_action :ensure_authenticated, only: %i[create reset verify]

      # POST /api/v1/reset_password.json
      # Creates a unique token, saves its digest to the user and emails it
      def create
        # TODO: Log events.
        return render_error unless params[:user]

        user = User.find_by email: params[:user][:email].downcase, provider: current_provider

        # Silently fail for unfound or external users.
        return render_data status: :ok unless user && !user.external_id?

        token = user.generate_reset_token!

        UserMailer.with(user:,
                        reset_url: reset_password_url(token), base_url: request.base_url,
                        provider: current_provider).reset_password_email.deliver_later

        render_data status: :ok
      end

      # POST /api/v1/reset_password/reset.json
      # Validates the token and resets the user's password
      def reset
        new_password = params[:user][:new_password]

        return render_error status: :bad_request if new_password.blank?

        # Invalidating token and changing the password.
        # TODO: Amir - optimise this.
        return render_error status: :internal_server_error unless @user.invalidate_reset_token

        @user.update! password: new_password

        render_data status: :ok
      end

      # POST /api/v1/reset_password/verify.json
      # Validates the token
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
    end
  end
end
