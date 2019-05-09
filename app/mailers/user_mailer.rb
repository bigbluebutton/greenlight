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

class UserMailer < ApplicationMailer
  default from: Rails.configuration.smtp_sender

  def verify_email(user, url, image, color)
    @user = user
    @url = url
    @image = image
    @color = color
    mail(to: @user.email, subject: t('landing.welcome'))
  end

  def password_reset(user, url, image, color)
    @user = user
    @url = url
    @image = image
    @color = color
    mail to: user.email, subject: t('reset_password.subtitle')
  end
end
