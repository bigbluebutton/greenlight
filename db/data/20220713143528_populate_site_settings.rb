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

class PopulateSiteSettings < ActiveRecord::Migration[7.0]
  def up
    SiteSetting.create! [
      { setting: Setting.find_by(name: 'PrimaryColor'), value: '#467fcf', provider: 'greenlight' },
      { setting: Setting.find_by(name: 'PrimaryColorLight'), value: '#e8eff9', provider: 'greenlight' },
      { setting: Setting.find_by(name: 'PrimaryColorDark'), value: '#316cbe', provider: 'greenlight' },
      { setting: Setting.find_by(name: 'BrandingImage'),
        value: ActionController::Base.helpers.image_path('bbb_logo.png'),
        provider: 'greenlight' },
      { setting: Setting.find_by(name: 'Terms'), value: '', provider: 'greenlight' },
      { setting: Setting.find_by(name: 'PrivacyPolicy'), value: '', provider: 'greenlight' },
      { setting: Setting.find_by(name: 'HelpCenter'), value: '', provider: 'greenlight' },
      { setting: Setting.find_by(name: 'RegistrationMethod'), value: SiteSetting::REGISTRATION_METHODS[:open], provider: 'greenlight' },
      { setting: Setting.find_by(name: 'ShareRooms'), value: 'true', provider: 'greenlight' },
      { setting: Setting.find_by(name: 'PreuploadPresentation'), value: 'true', provider: 'greenlight' },
      { setting: Setting.find_by(name: 'RoleMapping'), value: '', provider: 'greenlight' }
    ]
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
