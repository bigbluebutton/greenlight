# frozen_string_literal: true

class AddVisibilityToRolePermissions < ActiveRecord::Migration[7.1]
  def up
    visibility_permission = Permission.create!(name: 'AccessToVisibilities')

    Role.find_each do |role|
      RolePermission.create!(role:, permission: visibility_permission, value: Recording::VISIBILITIES.values)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
