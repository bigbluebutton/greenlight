# frozen_string_literal: true

class MigrationProduct < ActiveRecord::Base
  self.table_name = :roles
end

class SubMigrationProduct < ActiveRecord::Base
  self.table_name = :role_permissions
end

class AddManageRoomRecordingsToPermissions < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        MigrationProduct.all.each do |role|
          SubMigrationProduct.create(role_id: role.id, name: "can_manage_rooms_recordings",
            value: SubMigrationProduct.find_by(role_id: role.id, name: "can_manage_users").value, enabled: true)
        end
      end

      dir.down do
        MigrationProduct.all.each do |role|
          SubMigrationProduct.find_by(role_id: role.id, name: "can_manage_rooms_recordings").destroy
        end
      end
    end
  end
end
