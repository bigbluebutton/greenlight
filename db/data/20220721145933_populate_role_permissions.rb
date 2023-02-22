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

class PopulateRolePermissions < ActiveRecord::Migration[7.0]
  def up
    admin = Role.find_by(name: 'Administrator')
    user = Role.find_by(name: 'User')
    guest = Role.find_by(name: 'Guest')

    create_room = Permission.find_by(name: 'CreateRoom')
    manage_users = Permission.find_by(name: 'ManageUsers')
    manage_rooms = Permission.find_by(name: 'ManageRooms')
    manage_recordings = Permission.find_by(name: 'ManageRecordings')
    manage_site_settings = Permission.find_by(name: 'ManageSiteSettings')
    manage_roles = Permission.find_by(name: 'ManageRoles')
    shared_list = Permission.find_by(name: 'SharedList')
    can_record = Permission.find_by(name: 'CanRecord')

    RolePermission.create! [
      { role: admin, permission: create_room, value: 'true' },
      { role: admin, permission: manage_users, value: 'true' },
      { role: admin, permission: manage_rooms, value: 'true' },
      { role: admin, permission: manage_recordings, value: 'true' },
      { role: admin, permission: manage_site_settings, value: 'true' },
      { role: admin, permission: manage_roles, value: 'true' },
      { role: admin, permission: shared_list, value: 'true' },
      { role: admin, permission: can_record, value: 'true' },

      { role: user, permission: create_room, value: 'true' },
      { role: user, permission: manage_users, value: 'false' },
      { role: user, permission: manage_rooms, value: 'false' },
      { role: user, permission: manage_recordings, value: 'false' },
      { role: user, permission: manage_site_settings, value: 'false' },
      { role: user, permission: manage_roles, value: 'false' },
      { role: user, permission: shared_list, value: 'true' },
      { role: user, permission: can_record, value: 'true' },

      { role: guest, permission: create_room, value: 'false' },
      { role: guest, permission: manage_users, value: 'false' },
      { role: guest, permission: manage_rooms, value: 'false' },
      { role: guest, permission: manage_recordings, value: 'false' },
      { role: guest, permission: manage_site_settings, value: 'false' },
      { role: guest, permission: manage_roles, value: 'false' },
      { role: guest, permission: shared_list, value: 'true' },
      { role: guest, permission: can_record, value: 'true' }
    ]
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
