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
  def send_activation_email(user)
    return unless Rails.configuration.enable_email_verification

    @user = user
    UserMailer.verify_email(@user, user_verification_link, logo_image, user_color).deliver
  end

  # Sends password reset email.
  def send_password_reset_email(user)
    return unless Rails.configuration.enable_email_verification

    @user = user
    UserMailer.password_reset(@user, reset_link, logo_image, user_color).deliver_now
  end

  def send_user_promoted_email(user, role)
    return unless Rails.configuration.enable_email_verification

    UserMailer.user_promoted(user, role, root_url, logo_image, user_color).deliver_now
  end

  def send_user_demoted_email(user, role)
    return unless Rails.configuration.enable_email_verification

    UserMailer.user_demoted(user, role, root_url, logo_image, user_color).deliver_now
  end

  # Sends inivitation to join
  def send_invitation_email(name, email, token)
    return unless Rails.configuration.enable_email_verification

    @token = token
    UserMailer.invite_email(name, email, invitation_link, logo_image, user_color).deliver_now
  end

  def send_user_approved_email(user)
    return unless Rails.configuration.enable_email_verification

    UserMailer.approve_user(user, root_url, logo_image, user_color).deliver_now
  end

  def send_approval_user_signup_email(user)
    return unless Rails.configuration.enable_email_verification

    admin_emails = admin_emails()
    unless admin_emails.empty?
      UserMailer.approval_user_signup(user, admins_url, logo_image, user_color, admin_emails).deliver_now
    end
  end

  def send_invite_user_signup_email(user)
    return unless Rails.configuration.enable_email_verification

    admin_emails = admin_emails()
    unless admin_emails.empty?
      UserMailer.invite_user_signup(user, admins_url, logo_image, user_color, admin_emails).deliver_now
    end
  end

  private

  # Returns the link the user needs to click to verify their account
  def user_verification_link
    edit_account_activation_url(token: @user.activation_token, email: @user.email)
  end

  def admin_emails
    admins = User.all_users_with_roles.where(roles: { can_manage_users: true })

    if Rails.configuration.loadbalanced_configuration
      admins = admins.without_role(:super_admin)
                     .where(provider: user_settings_provider)
    end

    admins.collect(&:email).join(",")
  end

  def reset_link
    edit_password_reset_url(@user.reset_token, email: @user.email)
  end

  def invitation_link
    if allow_greenlight_users?
      signup_url(invite_token: @token)
    else
      root_url(invite_token: @token)
    end
  end
end
