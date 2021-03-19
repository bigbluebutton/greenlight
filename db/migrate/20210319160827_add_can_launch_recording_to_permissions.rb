# frozen_string_literal: true

class MigrationProduct < ActiveRecord::Base
  self.table_name = :roles
end

class SubMigrationProduct < ActiveRecord::Base
  self.table_name = :role_permissions
end

class AddCanLaunchRecordingToPermissions < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        MigrationProduct.all.each do |role|
          SubMigrationProduct.create(role_id: role.id, name: "can_launch_recording", value: 'true', enabled: true)
        end
      end
    end
  end
end
