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
