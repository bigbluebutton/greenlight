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

class PasswordResetsController < ApplicationController
  include Emailer

  before_action :disable_password_reset, unless: -> { Rails.configuration.enable_email_verification }
  before_action :find_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  # GET /password_resets/new
  def new
  end

  # POST /password_resets
  def create
    return redirect_to new_password_reset_path, flash: { alert: I18n.t("reset_password.captcha") } unless valid_captcha

    # Check if user exists and throw an error if he doesn't
    @user = User.find_by!(email: params[:password_reset][:email].downcase, provider: @user_domain)

    send_password_reset_email(@user, @user.create_reset_digest)
    redirect_to root_path
  rescue
    # User doesn't exist
    redirect_to root_path, flash: { success: I18n.t("email_sent", email_type: t("reset_password.subtitle")) }
  end

  # GET /password_resets/:id/edit
  def edit
  end

  # PATCH /password_resets/:id
  def update
    # Check if password is valid
    if params[:user][:password].empty?
      flash.now[:alert] = I18n.t("password_empty_notice")
    elsif params[:user][:password] != params[:user][:password_confirmation]
      # Password does not match password confirmation
      flash.now[:alert] = I18n.t("password_different_notice")
    elsif @user.update_attributes(user_params)
      # Clear the user's social uid if they are switching from a social to a local account
      @user.update_attribute(:social_uid, nil) if @user.social_uid.present?
      # Successfully reset password
      return redirect_to root_path, flash: { success: I18n.t("password_reset_success") }
    end

    render 'edit'
  end

  private

  def find_user
    @user = User.find_by(reset_digest: User.hash_token(params[:id]), provider: @user_domain)

    return redirect_to new_password_reset_url, alert: I18n.t("reset_password.invalid_token") unless @user
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # Checks expiration of reset token.
  def check_expiration
    redirect_to new_password_reset_url, alert: I18n.t("expired_reset_token") if @user.password_reset_expired?
  end

  # Redirects to 404 if emails are not enabled
  def disable_password_reset
    redirect_to '/404'
  end

  # Checks that the captcha passed is valid
  def valid_captcha
    return true unless Rails.configuration.recaptcha_enabled
    verify_recaptcha
  end
end
