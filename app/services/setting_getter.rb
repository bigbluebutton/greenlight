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
    @setting_name = setting_name
    @provider = provider
  end

  def call
    setting = SiteSetting.joins(:setting)
                         .find_by(
                           provider: @provider,
                           setting: { name: @setting_name }
                         )

    value = if @setting_name == 'BrandingImage' && setting.image.attached?
              rails_blob_path setting.image, only_path: true
            else
              setting&.value
            end

    transform_value(value)
  end

  private

  def transform_value(value)
    case value
    when 'true'
      true
    when 'false'
      false
    else
      value
    end
  end
end
