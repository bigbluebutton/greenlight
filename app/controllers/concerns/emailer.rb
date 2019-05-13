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
    @user = user
    UserMailer.verify_email(@user, user_verification_link, logo_image, user_color).deliver
  end

  # Sends password reset email.
  def send_password_reset_email(user)
    @user = user
    UserMailer.password_reset(@user, reset_link, logo_image, user_color).deliver_now
  end

  # Returns the link the user needs to click to verify their account
  def user_verification_link
    request.base_url + edit_account_activation_path(token: @user.activation_token, email: @user.email)
  end

  def reset_link
    request.base_url + edit_password_reset_path(@user.reset_token, email: @user.email)
  end
end
