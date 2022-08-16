# frozen_string_literal: true

class CreateRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.string :color, default: '', null: false
      t.string :provider, null: false
      t.timestamps
    end
  end
end
