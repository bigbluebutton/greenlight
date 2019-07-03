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
  include Pagy::Backend
  include Emailer
  include Registrar

  before_action :find_user, only: [:edit, :update, :destroy]
  before_action :ensure_unauthenticated, only: [:new, :create]

  # POST /u
  def create
    # Verify that GreenLight is configured to allow user signup.
    return unless Rails.configuration.allow_user_signup

    @user = User.new(user_params)
    @user.provider = @user_domain

    # User or recpatcha is not valid
    render(:new) && return unless valid_user_or_captcha

    # Redirect to root if user token is either invalid or expired
    return redirect_to root_path, flash: { alert: I18n.t("registration.invite.fail") } unless passes_invite_reqs

    # User has passed all validations required
    @user.save

    # Set user to pending and redirect if Approval Registration is set
    if approval_registration
      @user.add_role :pending

      return redirect_to root_path,
        flash: { success: I18n.t("registration.approval.signup") } unless Rails.configuration.enable_email_verification
    end

    send_registration_email if Rails.configuration.enable_email_verification

    # Sign in automatically if email verification is disabled or if user is already verified.
    login(@user) && return if !Rails.configuration.enable_email_verification || @user.email_verified

    send_verification

    redirect_to root_path
  end

  # GET /signin
  def signin
  end

  # GET /ldap_signin
  def ldap_signin
  end

  # GET /signup
  def new
    return redirect_to root_path unless Rails.configuration.allow_user_signup

    # Check if the user needs to be invited
    if invite_registration
      redirect_to root_path, flash: { alert: I18n.t("registration.invite.no_invite") } unless params[:invite_token]

      session[:invite_token] = params[:invite_token]
    end

    @user = User.new
  end

  # GET /u/:user_uid/edit
  def edit
    if current_user
      redirect_to current_user.main_room if @user != current_user && !current_user.admin_of?(@user)
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
    elsif current_user.admin_of?(@user)
      begin
        @user.destroy
      rescue => e
        logger.error "Error in user deletion: #{e}"
        flash[:alert] = I18n.t(params[:message], default: I18n.t("administrator.flash.delete_fail"))
      else
        flash[:success] = I18n.t("administrator.flash.delete")
      end
      redirect_to(admins_path) && return
    end
    redirect_to root_path
  end

  # GET /u/:user_uid/recordings
  def recordings
    if current_user && current_user.uid == params[:user_uid]
      @search, @order_column, @order_direction, recs =
        current_user.all_recordings(params.permit(:search, :column, :direction), true)
      @pagy, @recordings = pagy_array(recs)
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

  def ensure_unauthenticated
    redirect_to current_user.main_room if current_user
  end

  def user_params
    params.require(:user).permit(:name, :email, :image, :password, :password_confirmation,
      :new_password, :provider, :accepted_terms, :language)
  end

  def send_verification
    # Start email verification and redirect to root.
    begin
      send_activation_email(@user)
    rescue => e
      logger.error "Error in email delivery: #{e}"
      flash[:alert] = I18n.t(params[:message], default: I18n.t("delivery_error"))
    else
      flash[:success] = I18n.t("email_sent", email_type: t("verify.verification"))
    end
  end

  def send_registration_email
    begin
      if invite_registration
        send_invite_user_signup_email(@user)
      elsif approval_registration
        send_approval_user_signup_email(@user)
      end
    rescue => e
      logger.error "Error in email delivery: #{e}"
      flash[:alert] = I18n.t(params[:message], default: I18n.t("delivery_error"))
    end
  end

  # Add validation errors to model if they exist
  def valid_user_or_captcha
    valid_user = @user.valid?
    valid_captcha = Rails.configuration.recaptcha_enabled ? verify_recaptcha(model: @user) : true

    valid_user && valid_captcha
  end

  # Checks if the user passes the requirements to be invited
  def passes_invite_reqs
    # check if user needs to be invited and IS invited
    invitation = check_user_invited(@user.email, session[:invite_token], @user_domain)

    @user.email_verified = true if invitation[:verified]

    invitation[:present]
  end
end
