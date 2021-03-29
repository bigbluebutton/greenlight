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

module Registrar
  extend ActiveSupport::Concern

  def approval_registration
    @settings.get_value("Registration Method") == Rails.configuration.registration_methods[:approval]
  end

  def invite_registration
    @settings.get_value("Registration Method") == Rails.configuration.registration_methods[:invite]
  end

  # Returns a hash containing whether the user has been invited and if they
  # signed up with the same email that they were invited with
  def check_user_invited(email, token, domain)
    return { present: true, verified: false } unless invite_registration
    return { present: false, verified: false } if token.nil?

    invite = Invitation.valid.find_by(invite_token: token, provider: domain)
    if invite.present?
      # Check if they used the same email to sign up
      same_email = email.casecmp(invite.email).zero?
      invite.destroy
      { present: true, verified: same_email }
    else
      { present: false, verified: false }
    end
  end

  # Checks if the user passes the requirements to be invited
  def passes_invite_reqs
    # check if user needs to be invited and IS invited
    invitation = check_user_invited(@user.email, session[:invite_token], @user_domain)

    @user.email_verified = true if invitation[:verified]

    invitation[:present]
  end

  # Add validation errors to model if they exist
  def valid_user_or_captcha
    valid_user = @user.valid?
    valid_captcha = Rails.configuration.recaptcha_enabled ? verify_recaptcha(model: @user) : true

    logger.error("Support: #{@user.email} creation failed: User params are not valid.") unless valid_user

    valid_user && valid_captcha
  end

  # Checks if the user trying to sign in with twitter account
  def check_if_twitter_account(log_out = false)
    unless params[:old_twitter_user_id].nil? && session[:old_twitter_user_id].nil?
      logout if log_out
      flash.now[:alert] = I18n.t("registration.deprecated.new_signin")
      session[:old_twitter_user_id] = params[:old_twitter_user_id] unless params[:old_twitter_user_id].nil?
    end
  end
end
