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

class PopulateRoomLimitRolePermission < ActiveRecord::Migration[7.0]
  def up
    Permission.create! [
      { name: 'RoomLimit' }
    ]

    admin = Role.find_by(name: 'Administrator')
    user = Role.find_by(name: 'User')
    guest = Role.find_by(name: 'Guest')

    room_limit = Permission.find_by(name: 'RoomLimit')

    RolePermission.create! [

      { role: admin, permission: room_limit, value: '100' },
      { role: user, permission: room_limit, value: '100' },
      { role: guest, permission: room_limit, value: '100' }
    ]
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
