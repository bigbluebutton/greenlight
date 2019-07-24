# frozen_string_literal: true

class CreateRolePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :role_permissions do |t|
      t.belongs_to :role, index: true

      t.boolean :can_create_rooms, default: false
      t.boolean :send_promoted_email, default: false
      t.boolean :send_demoted_email, default: false
      t.boolean :administrator_role, default: false
      t.boolean :can_edit_site_settings, default: false
      t.boolean :can_edit_roles, default: false
      t.boolean :can_manage_users, default: false
      t.string  :role_colour

      t.timestamps
    end
  end
end
