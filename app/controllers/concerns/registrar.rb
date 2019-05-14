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

  def registration_method
    Setting.find_or_create_by!(provider: user_settings_provider).get_value("Registration Method")
  end

  def open_registration
     registration_method == Rails.configuration.registration_methods[:invite]
  end

  def approval_registration
     registration_method == Rails.configuration.registration_methods[:invite]
  end

  def invite_registration
     registration_method == Rails.configuration.registration_methods[:invite]
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
end
