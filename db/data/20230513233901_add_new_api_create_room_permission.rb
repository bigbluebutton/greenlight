# frozen_string_literal: true

class AddNewApiCreateRoomPermission < ActiveRecord::Migration[7.0]
  def up
    Permission.create! [
      { name: 'ApiCreateRoom' },
    ]

    admin = Role.find_by(name: 'Administrator')
    user = Role.find_by(name: 'User')
    guest = Role.find_by(name: 'Guest')

    api_create_room = Permission.find_by(name: 'ApiCreateRoom')

    RolePermission.create! [
      { role: admin, permission: api_create_room, value: 'true' },
      { role: user, permission: api_create_room, value: 'true' },
      { role: guest, permission: api_create_room, value: 'false' },
    ]
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
