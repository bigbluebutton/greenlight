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

    RolePermission.create! [
      { role: admin, permission: create_room, value: 'true', provider: 'greenlight' },
      { role: admin, permission: manage_users, value: 'true', provider: 'greenlight' },
      { role: admin, permission: manage_rooms, value: 'true', provider: 'greenlight' },
      { role: admin, permission: manage_recordings, value: 'true', provider: 'greenlight' },
      { role: admin, permission: manage_site_settings, value: 'true', provider: 'greenlight' },
      { role: admin, permission: manage_roles, value: 'true', provider: 'greenlight' },
      { role: admin, permission: shared_list, value: 'true', provider: 'greenlight' },

      { role: user, permission: create_room, value: 'true', provider: 'greenlight' },
      { role: user, permission: manage_users, value: 'false', provider: 'greenlight' },
      { role: user, permission: manage_rooms, value: 'false', provider: 'greenlight' },
      { role: user, permission: manage_recordings, value: 'false', provider: 'greenlight' },
      { role: user, permission: manage_site_settings, value: 'false', provider: 'greenlight' },
      { role: user, permission: manage_roles, value: 'false', provider: 'greenlight' },
      { role: user, permission: shared_list, value: 'true', provider: 'greenlight' },

      { role: guest, permission: create_room, value: 'false', provider: 'greenlight' },
      { role: guest, permission: manage_users, value: 'false', provider: 'greenlight' },
      { role: guest, permission: manage_rooms, value: 'false', provider: 'greenlight' },
      { role: guest, permission: manage_recordings, value: 'false', provider: 'greenlight' },
      { role: guest, permission: manage_site_settings, value: 'false', provider: 'greenlight' },
      { role: guest, permission: manage_roles, value: 'false', provider: 'greenlight' },
      { role: guest, permission: shared_list, value: 'true', provider: 'greenlight' }
    ]
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
