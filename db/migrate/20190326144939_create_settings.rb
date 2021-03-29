# frozen_string_literal: true

class CreateSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :settings do |t|
      t.string "provider", null: false
      t.timestamps
    end

    create_table :features do |t|
      t.belongs_to :setting
      t.string "name", null: false
      t.string "value"
      t.boolean "enabled", default: false
      t.timestamps
    end
  end
end
