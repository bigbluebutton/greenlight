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

module ThemingHelper
  # Returns the logo based on user's provider
  def logo_image
    Setting.find_or_create_by(provider: user_settings_provider)
           .get_value("Branding Image") || Rails.configuration.branding_image_default
  end

  # Returns the primary color based on user's provider
  def user_color
    Setting.find_or_create_by(provider: user_settings_provider)
           .get_value("Primary Color") || Rails.configuration.primary_color_default
  end

  # Returns the user's provider in the settings context
  def user_settings_provider
    if Rails.configuration.loadbalanced_configuration && current_user && !current_user&.has_role?(:super_admin)
      current_user.provider
    elsif Rails.configuration.loadbalanced_configuration
      @user_domain
    else
      "greenlight"
    end
  end
end
