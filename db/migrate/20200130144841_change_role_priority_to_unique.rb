# frozen_string_literal: true

class MigrationProduct < ActiveRecord::Base
  self.table_name = :roles
end

class ChangeRolePriorityToUnique < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        MigrationProduct.where("priority < 0").where.not(name: "pending").each do |role|
          role.decrement!(:priority)
        end

        add_index MigrationProduct, [:priority, :provider], unique: true
      end

      dir.down do
        remove_index MigrationProduct, [:priority, :provider]

        MigrationProduct.where("priority < 0").where.not(name: "pending").each do |role|
          role.increment!(:priority)
        end
      end
    end
  end
end
