# frozen_string_literal: true

class MigrationProduct < ActiveRecord::Base
  self.table_name = :users
end

class SubMigrationProduct < ActiveRecord::Base
  self.table_name = :roles
end

class AddRoleIdToUsers < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        add_reference :users, :role, index: true

        MigrationProduct.where(role_id: nil).each do |user|
          highest_role = SubMigrationProduct.joins("INNER JOIN users_roles ON users_roles.role_id = roles.id")
                                            .where("users_roles.user_id = '#{user.id}'")&.min_by(&:priority)&.id
          user.update_attributes(role_id: highest_role) unless highest_role.nil?
        end
      end

      dir.down do
        remove_reference :users, :role, index: true
      end
    end
  end
end
