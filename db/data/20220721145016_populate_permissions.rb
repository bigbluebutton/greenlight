# frozen_string_literal: true

class PopulatePermissions < ActiveRecord::Migration[7.0]
  def up
    Permission.create! [
      { name: 'CreateRoom' },
      { name: 'ManageUsers' },
      { name: 'ManageRooms' },
      { name: 'ManageRecordings' },
      { name: 'ManageSiteSettings' },
      { name: 'ManageRoles' },
      { name: 'SharedList' },
      { name: 'CanRecord' }
    ]
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
