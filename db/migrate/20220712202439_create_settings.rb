# frozen_string_literal: true

class CreateSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :settings, id: :uuid do |t|
      t.string :name, index: { unique: true }

      t.timestamps
    end
  end
end
