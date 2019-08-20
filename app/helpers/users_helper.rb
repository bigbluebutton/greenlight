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

module UsersHelper
  def recaptcha_enabled?
    Rails.configuration.recaptcha_enabled
  end

  def disabled_roles(user)
    current_user_role = current_user.highest_priority_role

    # Admins are able to remove the admin role from other admins
    # For all other roles they can only add/remove roles with a higher priority
    disallowed_roles = if current_user_role.name == "admin"
                          Role.editable_roles(@user_domain).where("priority < #{current_user_role.priority}")
                              .pluck(:id)
                        else
                          Role.editable_roles(@user_domain).where("priority <= #{current_user_role.priority}")
                              .pluck(:id)
                       end

    user.roles.by_priority.pluck(:id) | disallowed_roles
  end
end
