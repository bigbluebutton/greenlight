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

module Emailer
  extend ActiveSupport::Concern

  # Sends account activation email.
  def send_activation_email(user, token)
    begin
      return unless Rails.configuration.enable_email_verification

      UserMailer.verify_email(user, user_verification_link(token), @settings).deliver
    rescue => e
      logger.error "Support: Error in email delivery: #{e}"
      flash[:alert] = I18n.t(params[:message], default: I18n.t("delivery_error"))
    else
      flash[:success] = I18n.t("email_sent", email_type: t("verify.verification"))
    end
  end

  # Sends password reset email.
  def send_password_reset_email(user, token)
    begin
      return unless Rails.configuration.enable_email_verification

      UserMailer.password_reset(user, reset_link(token), @settings).deliver_now
    rescue => e
      logger.error "Support: Error in email delivery: #{e}"
      flash[:alert] = I18n.t(params[:message], default: I18n.t("delivery_error"))
    else
      flash[:success] = I18n.t("email_sent", email_type: t("reset_password.subtitle"))
    end
  end

  def send_user_promoted_email(user, role)
    begin
      return unless Rails.configuration.enable_email_verification

      UserMailer.user_promoted(user, role, root_url, @settings).deliver_now
    rescue => e
      logger.error "Support: Error in email delivery: #{e}"
      flash[:alert] = I18n.t(params[:message], default: I18n.t("delivery_error"))
    end
  end

  def send_user_demoted_email(user, role)
    begin
      return unless Rails.configuration.enable_email_verification

      UserMailer.user_demoted(user, role, root_url, @settings).deliver_now
    rescue => e
      logger.error "Support: Error in email delivery: #{e}"
      flash[:alert] = I18n.t(params[:message], default: I18n.t("delivery_error"))
    end
  end

  # Sends inivitation to join
  def send_invitation_email(name, email, token)
    begin
      return unless Rails.configuration.enable_email_verification

      UserMailer.invite_email(name, email, invitation_link(token), @settings).deliver_now
    rescue => e
      logger.error "Support: Error in email delivery: #{e}"
      flash[:alert] = I18n.t(params[:message], default: I18n.t("delivery_error"))
    else
      flash[:success] = I18n.t("administrator.flash.invite", email: email)
    end
  end

  def send_user_approved_email(user)
    begin
      return unless Rails.configuration.enable_email_verification

      UserMailer.approve_user(user, root_url, @settings).deliver_now
    rescue => e
      logger.error "Support: Error in email delivery: #{e}"
      flash[:alert] = I18n.t(params[:message], default: I18n.t("delivery_error"))
    else
      flash[:success] = I18n.t("email_sent", email_type: t("verify.verification"))
    end
  end

  def send_approval_user_signup_email(user)
    begin
      return unless Rails.configuration.enable_email_verification

      admin_emails = admin_emails()
      UserMailer.approval_user_signup(user, admins_url(tab: "pending"),
      admin_emails, @settings).deliver_now unless admin_emails.empty?
    rescue => e
      logger.error "Support: Error in email delivery: #{e}"
      flash[:alert] = I18n.t(params[:message], default: I18n.t("delivery_error"))
    end
  end

  def send_invite_user_signup_email(user)
    begin
      return unless Rails.configuration.enable_email_verification

      admin_emails = admin_emails()
      UserMailer.invite_user_signup(user, admins_url, admin_emails, @settings).deliver_now unless admin_emails.empty?
    rescue => e
      logger.error "Support: Error in email delivery: #{e}"
      flash[:alert] = I18n.t(params[:message], default: I18n.t("delivery_error"))
    end
  end

  private

  # Returns the link the user needs to click to verify their account
  def user_verification_link(token)
    edit_account_activation_url(token: token)
  end

  def admin_emails
    admins = User.all_users_with_roles.where(roles: { role_permissions: { name: "can_manage_users", value: "true" } })

    if Rails.configuration.loadbalanced_configuration
      admins = admins.without_role(:super_admin)
                     .where(provider: @user_domain)
    end

    admins.collect(&:email).join(",")
  end

  def reset_link(token)
    edit_password_reset_url(token)
  end

  def invitation_link(token)
    if allow_greenlight_accounts?
      signup_url(invite_token: token)
    else
      root_url(invite_token: token)
    end
  end
end
