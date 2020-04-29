# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

class AccountActivationsController < ApplicationController
  include Emailer

  before_action :ensure_unauthenticated
  before_action :find_user

  # GET /account_activations
  def show
  end

  # GET /account_activations/edit
  def edit
    # If the user exists and is not verified and provided the correct token
    if @user && !@user.activated?
      # Verify user
      @user.activate

      # Redirect user to root with account pending flash if account is still pending
      return redirect_to root_path,
        flash: { success: I18n.t("registration.approval.signup") } if @user.has_role?(:pending)

      # Redirect user to sign in path with success flash
      redirect_to signin_path, flash: { success: I18n.t("verify.activated") + " " + I18n.t("verify.signin") }
    else
      redirect_to root_path, flash: { alert: I18n.t("verify.invalid") }
    end
  end

  # GET /account_activations/resend
  def resend
    if @user.activated?
      # User is already verified
      flash[:alert] = I18n.t("verify.already_verified")
    else
      # Resend
      send_activation_email(@user, @user.create_activation_token)
    end

    redirect_to root_path
  end

  private

  def find_user
    @user = User.find_by!(activation_digest: User.hash_token(params[:token]), provider: @user_domain)
  end

  def ensure_unauthenticated
    redirect_to current_user.main_room if current_user
  end
end
