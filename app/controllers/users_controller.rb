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
  include Pagy::Backend
  include Authenticator
  include Emailer
  include Registrar
  include Recorder
  include Rolify

  before_action :find_user, only: [:edit, :change_password, :delete_account, :update]
  before_action :ensure_unauthenticated_except_twitter, only: [:create]
  before_action :check_user_signup_allowed, only: [:create]
  before_action :check_admin_of, only: [:edit, :change_password, :delete_account]

  # POST /u
  def create
    @user = User.new(user_params)
    @user.provider = @user_domain

    # User or recpatcha is not valid
    render("sessions/new") && return unless valid_user_or_captcha

    # Redirect to root if user token is either invalid or expired
    return redirect_to root_path, flash: { alert: I18n.t("registration.invite.fail") } unless passes_invite_reqs

    # User has passed all validations required
    @user.save

    logger.info "Support: #{@user.email} user has been created."

    # Set user to pending and redirect if Approval Registration is set
    if approval_registration
      @user.add_role :pending

      return redirect_to root_path,
        flash: { success: I18n.t("registration.approval.signup") } unless Rails.configuration.enable_email_verification
    end

    send_registration_email

    # Sign in automatically if email verification is disabled or if user is already verified.
    login(@user) && return if !Rails.configuration.enable_email_verification || @user.email_verified

    @user.create_activation_token

    send_activation_email(@user)

    redirect_to root_path
  end

  # GET /u/:user_uid/edit
  def edit
    redirect_to root_path unless current_user
  end

  # GET /u/:user_uid/change_password
  def change_password
    redirect_to edit_user_path unless current_user.greenlight_account?
  end

  # GET /u/:user_uid/delete_account
  def delete_account
  end

  # PATCH /u/:user_uid/edit
  def update
    profile = params[:setting] == "password" ? change_password_path(@user) : edit_user_path(@user)
    if session[:prev_url].present?
      path = session[:prev_url]
      session.delete(:prev_url)
    else
      path = admins_path
    end

    redirect_path = current_user.admin_of?(@user) ? path : profile

    if params[:setting] == "password"
      # Update the users password.

      if @user.authenticate(user_params[:password])
        # Verify that the new passwords match.
        if user_params[:new_password] == user_params[:password_confirmation]
          @user.password = user_params[:new_password]
        else
          # New passwords don't match.
          @user.errors.add(:password_confirmation, "doesn't match")
        end
      else
        # Original password is incorrect, can't update.
        @user.errors.add(:password, "is incorrect")
      end

      # Notify the user that their account has been updated.
      return redirect_to redirect_path,
        flash: { success: I18n.t("info_update_success") } if @user.errors.empty? && @user.save

      render :change_password
    else
      if @user.update_attributes(user_params)
        @user.update_attributes(email_verified: false) if user_params[:email] != @user.email

        user_locale(@user)

        if update_roles(params[:user][:role_ids])
          return redirect_to redirect_path, flash: { success: I18n.t("info_update_success") }
        else
          flash[:alert] = I18n.t("administrator.roles.invalid_assignment")
        end
      end

      render :edit
    end
  end

  # DELETE /u/:user_uid
  def destroy
    # Include deleted users in the check
    @user = User.include_deleted.find_by(uid: params[:user_uid])

    logger.info "Support: #{current_user.email} is deleting #{@user.email}."

    self_delete = current_user == @user
    redirect_url = self_delete ? root_path : admins_path

    begin
      if current_user && (self_delete || current_user.admin_of?(@user))
        # Permanently delete if the user is deleting themself
        perm_delete = self_delete || (params[:permanent].present? && params[:permanent] == "true")

        # Permanently delete the rooms under the user if they have not been reassigned
        if perm_delete
          @user.rooms.include_deleted.each do |room|
            room.destroy(true)
          end
        end

        @user.destroy(perm_delete)

        # Log the user out if they are deleting themself
        session.delete(:user_id) if self_delete

        return redirect_to redirect_url, flash: { success: I18n.t("administrator.flash.delete") } unless self_delete
      else
        flash[:alert] = I18n.t("administrator.flash.delete_fail")
      end
    rescue => e
      logger.error "Support: Error in user deletion: #{e}"
      flash[:alert] = I18n.t(params[:message], default: I18n.t("administrator.flash.delete_fail"))
    end

    redirect_to redirect_url
  end

  # GET /u/:user_uid/recordings
  def recordings
    if current_user && current_user.uid == params[:user_uid]
      @search, @order_column, @order_direction, recs =
        all_recordings(current_user.rooms.pluck(:bbb_id), params.permit(:search, :column, :direction), true)
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
    @user = User.find_by(uid: params[:user_uid])
  end

  # Verify that GreenLight is configured to allow user signup.
  def check_user_signup_allowed
    redirect_to root_path unless Rails.configuration.allow_user_signup
  end

  def user_params
    params.require(:user).permit(:name, :email, :image, :password, :password_confirmation,
      :new_password, :provider, :accepted_terms, :language, :time_zone)
  end

  def send_registration_email
    if invite_registration
      send_invite_user_signup_email(@user)
    elsif approval_registration
      send_approval_user_signup_email(@user)
    end
  end

  # Checks that the user is allowed to edit this user
  def check_admin_of
    redirect_to current_user.main_room if current_user && @user != current_user && !current_user.admin_of?(@user)
  end
end
