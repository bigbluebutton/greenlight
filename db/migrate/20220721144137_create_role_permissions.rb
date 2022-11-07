# frozen_string_literal: true

class CreateRolePermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :role_permissions, id: :uuid do |t|
      t.belongs_to :role, foreign_key: true, type: :uuid
      t.belongs_to :permission, foreign_key: true, type: :uuid
      t.string :value, null: false

      t.timestamps
    end
  end
end
