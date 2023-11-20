# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def test_email
    UserMailer.with(to: 'user@users.com', subject: 'Test Subject').test_email
  end

  def reset_password_email
    fake_user = Struct.new(:name, :email)

    UserMailer.with(user: fake_user.new('user', 'user@users.com'), reset_url: 'https://example.com/reset').reset_password_email
  end

  def activate_account_email
    fake_user = Struct.new(:name, :email)

    UserMailer.with(user: fake_user.new('user', 'user@users.com'), activation_url: 'https://example.com/activate').activate_account_email
  end

  def invitation_email
    fake_user = Struct.new(:name, :email)

    UserMailer.with(user: fake_user.new('user', 'user@users'), invitation_url: 'https://example.com/invite').invitation_email
  end

  def new_user_signup_email
    fake_user = Struct.new(:name, :email)

    UserMailer.with(user: fake_user.new('user', 'user@users')).new_user_signup_email
  end
end
