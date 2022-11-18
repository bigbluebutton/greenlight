# frozen_string_literal: true

class PopulateSuperAdminRolePermissions < ActiveRecord::Migration[7.0]
  def up
    Role.create! [
      { name: 'SuperAdmin', provider: 'bn' },
    ]

    super_admin = Role.find_by(name: 'SuperAdmin')
   
    create_room = Permission.find_by(name: 'CreateRoom')
    manage_users = Permission.find_by(name: 'ManageUsers')
    manage_rooms = Permission.find_by(name: 'ManageRooms')
    manage_recordings = Permission.find_by(name: 'ManageRecordings')
    manage_site_settings = Permission.find_by(name: 'ManageSiteSettings')
    manage_roles = Permission.find_by(name: 'ManageRoles')
    shared_list = Permission.find_by(name: 'SharedList')
    can_record = Permission.find_by(name: 'CanRecord')
    room_limit = Permission.find_by(name: 'RoomLimit')

    RolePermission.create! [
      { role: super_admin, permission: create_room, value: 'true' },
      { role: super_admin, permission: manage_users, value: 'true' },
      { role: super_admin, permission: manage_rooms, value: 'true' },
      { role: super_admin, permission: manage_recordings, value: 'true' },
      { role: super_admin, permission: manage_site_settings, value: 'true' },
      { role: super_admin, permission: manage_roles, value: 'true' },
      { role: super_admin, permission: shared_list, value: 'true' },
      { role: super_admin, permission: can_record, value: 'true' },
      { role: super_admin, permission: room_limit, value: '100' }
    ]
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
