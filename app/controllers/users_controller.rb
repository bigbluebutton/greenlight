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

class UsersController < ApplicationController
  before_action :find_user, only: [:edit, :update, :destroy]
  before_action :ensure_unauthenticated, only: [:new, :create]

  # POST /u
  def create
    # Verify that GreenLight is configured to allow user signup.
    return unless Rails.configuration.allow_user_signup

    @user = User.new(user_params)
    @user.provider = "greenlight"

    if Rails.configuration.enable_email_verification && @user.save
      begin
        UserMailer.verify_email(@user, verification_link(@user)).deliver
        login(@user)
      rescue => e
        logger.error "Error in email delivery: #{e}"
        mailer_delivery_fail
      end
    elsif @user.save
      login(@user)
    else
      # Handle error on user creation.
      render :new
    end
  end

  # GET /signup
  def new
    if Rails.configuration.allow_user_signup
      @user = User.new
    else
      redirect_to root_path
    end
  end

  # GET /u/:user_uid/edit
  def edit
    if current_user
      redirect_to current_user.room unless @user == current_user
    else
      redirect_to root_path
    end
  end

  # PATCH /u/:user_uid/edit
  def update
    if params[:setting] == "password"
      # Update the users password.
      errors = {}

      if @user.authenticate(user_params[:password])
        # Verify that the new passwords match.
        if user_params[:new_password] == user_params[:password_confirmation]
          @user.password = user_params[:new_password]
        else
          # New passwords don't match.
          errors[:password_confirmation] = "doesn't match"
        end
      else
        # Original password is incorrect, can't update.
        errors[:password] = "is incorrect"
      end

      if errors.empty? && @user.save
        # Notify the user that their account has been updated.
        redirect_to edit_user_path(@user), notice: I18n.t("info_update_success")
      else
        # Append custom errors.
        errors.each { |k, v| @user.errors.add(k, v) }
        render :edit, params: { settings: params[:settings] }
      end
    elsif user_params[:email] != @user.email && @user.update_attributes(user_params)
      @user.update_attributes(email_verified: false)
      redirect_to edit_user_path(@user), notice: I18n.t("info_update_success")
    elsif @user.update_attributes(user_params)
      redirect_to edit_user_path(@user), notice: I18n.t("info_update_success")
    else
      render :edit, params: { settings: params[:settings] }
    end
  end

  # DELETE /u/:user_uid
  def destroy
    if current_user && current_user == @user
      @user.destroy
      session.delete(:user_id)
    end
    redirect_to root_path
  end

  # GET | POST /terms
  def terms
    redirect_to '/404' unless Rails.configuration.terms

    if params[:accept] == "true"
      current_user.update_attributes(accepted_terms: true)
      login(current_user)
    end
  end

  # GET | POST /u/verify/confirm
  def confirm
    if !current_user || current_user.uid != params[:user_uid]
      redirect_to '/404'
    elsif current_user.email_verified
      login(current_user)
    elsif params[:email_verified] == "true"
      current_user.update_attributes(email_verified: true)
      login(current_user)
    else
      render 'verify'
    end
  end

  # GET /u/verify/resend
  def resend
    if !current_user
      redirect_to '/404'
    elsif current_user.email_verified
      login(current_user)
    elsif params[:email_verified] == "false"
      begin
        UserMailer.verify_email(current_user, verification_link(current_user)).deliver
        render 'verify'
      rescue => e
        logger.error "Error in email delivery: #{e}"
        mailer_delivery_fail
      end
    else
      render 'verify'
    end
  end

  private

  def mailer_delivery_fail
    redirect_to root_path, notice: I18n.t(params[:message], default: I18n.t("delivery_error"))
  end

  def verification_link(user)
    request.base_url + confirm_path(user.uid)
  end

  def find_user
    @user = User.find_by!(uid: params[:user_uid])
  end

  def ensure_unauthenticated
    redirect_to current_user.main_room if current_user
  end

  def user_params
    params.require(:user).permit(:name, :email, :image, :password, :password_confirmation,
      :new_password, :provider, :accepted_terms)
  end
end
