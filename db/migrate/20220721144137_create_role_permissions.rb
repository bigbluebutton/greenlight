# frozen_string_literal: true

class CreateRolePermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :role_permissions do |t|
      t.belongs_to :role, foreign_key: true
      t.belongs_to :permission, foreign_key: true
      t.string :value, null: false

      t.timestamps
    end
  end
end
