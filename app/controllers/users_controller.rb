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
  include RecordingsHelper

  before_action :find_user, only: [:edit, :update, :destroy]
  before_action :ensure_unauthenticated, only: [:new, :create]

  # POST /u
  def create
    # Verify that GreenLight is configured to allow user signup.
    return unless Rails.configuration.allow_user_signup

    @user = User.new(user_params)
    @user.provider = @user_domain

    # Handle error on user creation.
    render(:new) && return unless @user.save

    # Sign in automatically if email verification is disabled.
    login(@user) && return unless Rails.configuration.enable_email_verification

    # Start email verification and redirect to root.
    begin
      @user.send_activation_email(verification_link)
    rescue => e
      logger.error "Error in email delivery: #{e}"
      flash[:alert] = I18n.t(params[:message], default: I18n.t("delivery_error"))
    else
      flash[:success] = I18n.t("email_sent")
    end
    redirect_to(root_path)
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
        flash[:success] = I18n.t("info_update_success")
        redirect_to edit_user_path(@user)
      else
        # Append custom errors.
        errors.each { |k, v| @user.errors.add(k, v) }
        render :edit, params: { settings: params[:settings] }
      end
    elsif user_params[:email] != @user.email && @user.update_attributes(user_params)
      @user.update_attributes(email_verified: false)
      flash[:success] = I18n.t("info_update_success")
      redirect_to edit_user_path(@user)
    elsif @user.update_attributes(user_params)
      update_locale(@user)
      flash[:success] = I18n.t("info_update_success")
      redirect_to edit_user_path(@user)
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

  # GET /u/:user_uid/recordings
  def recordings
    if current_user && current_user.uid == params[:user_uid]
      @recordings = current_user.all_recordings
    else
      redirect_to root_path
    end
  end

  # GET | POST /terms
  def terms
    redirect_to '/404' unless Rails.configuration.terms

    if params[:accept] == "true"
      current_user.update_attributes(accepted_terms: true)
      login(current_user)
    end
  end

  private

  def find_user
    @user = User.find_by!(uid: params[:user_uid])
  end

  def verification_link
    request.base_url + edit_account_activation_path(token: @user.activation_token, email: @user.email)
  end

  def ensure_unauthenticated
    redirect_to current_user.main_room if current_user
  end

  def user_params
    params.require(:user).permit(:name, :email, :image, :password, :password_confirmation,
      :new_password, :provider, :accepted_terms, :language)
  end
end
