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

module AdminsHelper
  include Pagy::Frontend

  def display_invite
    current_page?(admins_path) && invite_registration
  end

  def registration_method
    Setting.find_or_create_by!(provider: user_settings_provider).get_value("Registration Method")
  end

  def invite_registration
    registration_method == Rails.configuration.registration_methods[:invite]
  end

  def approval_registration
    registration_method == Rails.configuration.registration_methods[:approval]
  end

  def room_authentication_string
    if Setting.find_or_create_by!(provider: user_settings_provider).get_value("Room Authentication") == "true"
      I18n.t("administrator.site_settings.authentication.enabled")
    else
      I18n.t("administrator.site_settings.authentication.disabled")
    end
  end

  def registration_method_string
    case registration_method
    when Rails.configuration.registration_methods[:open]
        I18n.t("administrator.site_settings.registration.methods.open")
    when Rails.configuration.registration_methods[:invite]
        I18n.t("administrator.site_settings.registration.methods.invite")
    when Rails.configuration.registration_methods[:approval]
        I18n.t("administrator.site_settings.registration.methods.approval")
      end
  end

  def room_limit_number
    Setting.find_or_create_by!(provider: user_settings_provider).get_value("Room Limit").to_i
  end
end
