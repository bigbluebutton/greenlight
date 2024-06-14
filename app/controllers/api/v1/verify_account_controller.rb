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
    class VerifyAccountController < ApiController
      include ClientRoutable

      skip_before_action :ensure_authenticated, only: %i[create activate]
      before_action :find_user_and_authorize, only: :create

      # POST /api/v1/verify_account.json
      # Creates a unique token, saves its digest to the user and emails it
      def create
        token = @user.generate_activation_token!

        UserMailer.with(user: @user, activation_url: activate_account_url(token),
                        base_url: request.base_url, provider: current_provider).activate_account_email.deliver_later

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

        @user = User.find_by id: params[:user][:id], provider: current_provider
        render_data status: :ok unless @user && !@user.verified?
      end
    end
  end
end
