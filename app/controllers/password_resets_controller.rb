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
  before_action :find_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def index
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      send_password_reset_email(@user)
      flash[:success] = I18n.t("email_sent", email_type: t("reset_password.subtitle"))
      redirect_to root_path
    else
      flash[:alert] = I18n.t("no_user_email_exists")
      redirect_to new_password_reset_path
    end
  rescue => e
    logger.error "Error in email delivery: #{e}"
    redirect_to root_path, alert: I18n.t(params[:message], default: I18n.t("delivery_error"))
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      flash.now[:alert] = I18n.t("password_empty_notice")
      render 'edit'
    elsif params[:user][:password] != params[:user][:password_confirmation]
      flash.now[:alert] = I18n.t("password_different_notice")
      render 'edit'
    elsif current_user.update_attributes(user_params)
      flash[:success] = I18n.t("password_reset_success")
      redirect_to root_path
    else
      render 'edit'
    end
  end

  private

  def find_user
    @user = User.find_by(email: params[:email])
  end

  def current_user
    @user
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # Checks expiration of reset token.
  def check_expiration
    redirect_to new_password_reset_url, alert: I18n.t("expired_reset_token") if current_user.password_reset_expired?
  end

  # Confirms a valid user.
  def valid_user
    unless current_user.authenticated?(:reset, params[:id])
      current_user&.activate unless current_user&.activated?
      redirect_to root_url
    end
  end

  def disable_password_reset
    redirect_to '/404'
  end
end
