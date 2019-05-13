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
    render :verify
  end

  # GET /account_activations/edit
  def edit
    if @user && !@user.activated? && @user.authenticated?(:activation, params[:token])
      @user.activate

      flash[:success] = I18n.t("verify.activated") + " " + I18n.t("verify.signin")
      redirect_to signin_path
    else
      flash[:alert] = I18n.t("verify.invalid")
      redirect_to root_path
    end
  end

  # GET /account_activations/resend
  def resend
    if @user.activated?
      flash[:alert] = I18n.t("verify.already_verified")
    else
      begin
        send_activation_email(@user)
      rescue => e
        logger.error "Error in email delivery: #{e}"
        flash[:alert] = I18n.t(params[:message], default: I18n.t("delivery_error"))
      else
        flash[:success] = I18n.t("email_sent", email_type: t("verify.verification"))
      end
    end

    redirect_to(root_path)
  end

  private

  def ensure_unauthenticated
    redirect_to current_user.main_room if current_user
  end

  def email_params
    params.require(:email).permit(:email, :token)
  end

  def find_user
    @user = User.find_by!(email: params[:email], provider: @user_domain)
  end
end
