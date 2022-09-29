# frozen_string_literal: true

class PopulateRoomLimitPermission < ActiveRecord::Migration[7.0]
  def up
    Permission.create! [
      { name: 'RoomLimit' }
    ]
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
