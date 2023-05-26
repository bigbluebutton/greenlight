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

class SettingGetter
  include Rails.application.routes.url_helpers

  def initialize(setting_name:, provider:)
    @setting_name = Array(setting_name)
    @provider = provider
  end

  def call
    # Fetch the site settings records while eager loading their respective settings ↓
    site_settings = SiteSetting.includes(:setting)
                               .where(
                                 provider: @provider,
                                 setting: { name: @setting_name }
                               )

    # Pessimist check: Pass only if all provided names were found ↓
    return nil unless @setting_name.size == site_settings.size

    site_settings_hash = {}

    # In memory prepare the result hash ↓
    site_settings.map do |site_setting|
      site_settings_hash[site_setting.setting.name] = transform_value(site_setting)
    end

    # If there's only one setting is being fetched no need for a hash ↓
    return site_settings_hash.values.first if site_settings_hash.size == 1

    # A Hash<setting_name => parsed_value> is returned otherwise ↓
    site_settings_hash
  end

  private

  def transform_value(site_setting)
    if site_setting.setting.name == 'BrandingImage'
      return rails_blob_path site_setting.image, only_path: true if site_setting.image.attached?

      return ActionController::Base.helpers.image_path('bbb_logo.png')
    end

    case site_setting.value
    when 'true'
      true
    when 'false'
      false
    else
      site_setting.value
    end
  end
end
