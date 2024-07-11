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

# Creates the roles, site settings, and room config options for the given tenant.
class TenantSetup
  def initialize(provider)
    @provider = provider
  end

  def call
    create_roles
    create_site_settings
    create_rooms_configs_options
    create_role_permissions
  end

  def create_roles
    Role.create! [
      { name: 'Administrator', provider: @provider },
      { name: 'User', provider: @provider },
      { name: 'Guest', provider: @provider }
    ]
  end

  def create_site_settings
    SiteSetting.create! [
      { setting: Setting.find_by(name: 'PrimaryColor'), value: '#467fcf', provider: @provider },
      { setting: Setting.find_by(name: 'PrimaryColorLight'), value: '#e8eff9', provider: @provider },
      { setting: Setting.find_by(name: 'PrimaryColorDark'), value: '#316cbe', provider: @provider },
      { setting: Setting.find_by(name: 'BrandingImage'),
        value: ActionController::Base.helpers.image_path('bbb_logo.png'),
        provider: @provider },
      { setting: Setting.find_by(name: 'Terms'), value: '', provider: @provider },
      { setting: Setting.find_by(name: 'PrivacyPolicy'), value: '', provider: @provider },
      { setting: Setting.find_by(name: 'HelpCenter'), value: '', provider: @provider },
      { setting: Setting.find_by(name: 'RegistrationMethod'), value: SiteSetting::REGISTRATION_METHODS[:open],
        provider: @provider },
      { setting: Setting.find_by(name: 'ShareRooms'), value: 'true', provider: @provider },
      { setting: Setting.find_by(name: 'PreuploadPresentation'), value: 'true', provider: @provider },
      { setting: Setting.find_by(name: 'RoleMapping'), value: '', provider: @provider },
      { setting: Setting.find_by(name: 'DefaultRole'), provider: @provider, value: 'User' },
      { setting: Setting.find_by(name: 'DefaultRecordingVisibility'), provider: @provider, value: 'Published' },
      { setting: Setting.find_by(name: 'Maintenance'), provider: @provider, value: '' },
      { setting: Setting.find_by(name: 'SessionTimeout'), provider: @provider, value: '1' }
    ]
  end

  def create_rooms_configs_options
    RoomsConfiguration.create! [
      { meeting_option: MeetingOption.find_by(name: 'record'), value: 'default_enabled', provider: @provider },
      { meeting_option: MeetingOption.find_by(name: 'muteOnStart'), value: 'optional', provider: @provider },
      { meeting_option: MeetingOption.find_by(name: 'guestPolicy'), value: 'optional', provider: @provider },
      { meeting_option: MeetingOption.find_by(name: 'glAnyoneCanStart'), value: 'optional', provider: @provider },
      { meeting_option: MeetingOption.find_by(name: 'glAnyoneJoinAsModerator'), value: 'optional', provider: @provider },
      { meeting_option: MeetingOption.find_by(name: 'glRequireAuthentication'), value: 'optional', provider: @provider },
      { meeting_option: MeetingOption.find_by(name: 'glViewerAccessCode'), value: 'optional', provider: @provider },
      { meeting_option: MeetingOption.find_by(name: 'glModeratorAccessCode'), value: 'optional', provider: @provider }
    ]
  end

  def create_role_permissions
    admin = Role.find_by(name: 'Administrator', provider: @provider)
    user = Role.find_by(name: 'User', provider: @provider)
    guest = Role.find_by(name: 'Guest', provider: @provider)

    create_room = Permission.find_by(name: 'CreateRoom')
    manage_users = Permission.find_by(name: 'ManageUsers')
    manage_rooms = Permission.find_by(name: 'ManageRooms')
    manage_recordings = Permission.find_by(name: 'ManageRecordings')
    manage_site_settings = Permission.find_by(name: 'ManageSiteSettings')
    manage_roles = Permission.find_by(name: 'ManageRoles')
    shared_list = Permission.find_by(name: 'SharedList')
    can_record = Permission.find_by(name: 'CanRecord')
    room_limit = Permission.find_by(name: 'RoomLimit')
    access_to_visbilities = Permission.find_by(name: 'AccessToVisibilities')

    RolePermission.create! [
      { role: admin, permission: create_room, value: 'true' },
      { role: admin, permission: manage_users, value: 'true' },
      { role: admin, permission: manage_rooms, value: 'true' },
      { role: admin, permission: manage_recordings, value: 'true' },
      { role: admin, permission: manage_site_settings, value: 'true' },
      { role: admin, permission: manage_roles, value: 'true' },
      { role: admin, permission: shared_list, value: 'true' },
      { role: admin, permission: can_record, value: 'true' },
      { role: admin, permission: room_limit, value: '100' },
      { role: admin, permission: access_to_visbilities, value: Recording::VISIBILITIES.values },

      { role: user, permission: create_room, value: 'true' },
      { role: user, permission: manage_users, value: 'false' },
      { role: user, permission: manage_rooms, value: 'false' },
      { role: user, permission: manage_recordings, value: 'false' },
      { role: user, permission: manage_site_settings, value: 'false' },
      { role: user, permission: manage_roles, value: 'false' },
      { role: user, permission: shared_list, value: 'true' },
      { role: user, permission: can_record, value: 'true' },
      { role: user, permission: room_limit, value: '100' },
      { role: user, permission: access_to_visbilities, value: Recording::VISIBILITIES.values },

      { role: guest, permission: create_room, value: 'false' },
      { role: guest, permission: manage_users, value: 'false' },
      { role: guest, permission: manage_rooms, value: 'false' },
      { role: guest, permission: manage_recordings, value: 'false' },
      { role: guest, permission: manage_site_settings, value: 'false' },
      { role: guest, permission: manage_roles, value: 'false' },
      { role: guest, permission: shared_list, value: 'true' },
      { role: guest, permission: can_record, value: 'true' },
      { role: guest, permission: room_limit, value: '100' },
      { role: guest, permission: access_to_visbilities, value: Recording::VISIBILITIES.values }
    ]
  end
end
