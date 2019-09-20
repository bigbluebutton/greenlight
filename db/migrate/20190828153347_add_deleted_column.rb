# frozen_string_literal: true

class AddDeletedColumn < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :deleted, :boolean, null: false, default: false
    add_index :users, :deleted
    add_column :rooms, :deleted, :boolean, null: false, default: false
    add_index :rooms, :deleted
  end
end
