# frozen_string_literal: true

class RoleCreator
  def initialize(name:, provider:)
    @name = name
    @provider = provider
  end

  def call
    role = Role.new(name: @name, provider: @provider)

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
      { role:, permission: create_room, value: 'false' },
      { role:, permission: manage_users, value: 'false' },
      { role:, permission: manage_rooms, value: 'false' },
      { role:, permission: manage_recordings, value: 'false' },
      { role:, permission: manage_site_settings, value: 'false' },
      { role:, permission: manage_roles, value: 'false' },
      { role:, permission: shared_list, value: 'false' },
      { role:, permission: can_record, value: 'false' },
      { role:, permission: room_limit, value: '0' }
    ]

    role
  end
end
