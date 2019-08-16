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

  # Gets the email of the room owner to which the recording belongs to
  def recording_owner_email(room_id)
    Room.find_by(bbb_id: room_id).owner.email
  end

  def invite_registration
    @settings.get_value("Registration Method") == Rails.configuration.registration_methods[:invite]
  end

  def room_authentication_string
    if @settings.get_value("Room Authentication") == "true"
      I18n.t("administrator.site_settings.authentication.enabled")
    else
      I18n.t("administrator.site_settings.authentication.disabled")
    end
  end

  def recording_default_visibility_string
    if @settings.get_value("Default Recording Visibility") == "public"
      I18n.t("recording.visibility.public")
    else
      I18n.t("recording.visibility.unlisted")
    end
  end

  def registration_method_string
    case @settings.get_value("Registration Method")
    when Rails.configuration.registration_methods[:open]
        I18n.t("administrator.site_settings.registration.methods.open")
    when Rails.configuration.registration_methods[:invite]
        I18n.t("administrator.site_settings.registration.methods.invite")
    when Rails.configuration.registration_methods[:approval]
        I18n.t("administrator.site_settings.registration.methods.approval")
      end
  end

  def room_limit_number
    @settings.get_value("Room Limit").to_i
  end

  def edit_disabled
    @edit_disabled ||= @selected_role.priority <= current_user.highest_priority_role.priority
  end
end
