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

module ApplicationHelper
  def branding_image
    asset_path = SettingGetter.new(setting_name: 'BrandingImage', provider: current_provider).call
    asset_url(asset_path)
  end

  def page_title
    match = request&.url&.match('\/rooms\/(\w{3}-\w{3}-\w{3}-\w{3})')
    return 'BigBlueButton' if match.blank?

    room_name = Room.find_by(friendly_id: match[1])&.name
    room_name || 'BigBlueButton'
  end
end
