# frozen_string_literal: true

class CreateSharedAccesses < ActiveRecord::Migration[7.0]
  def change
    create_table :shared_accesses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true

      t.index %i[user_id room_id], unique: true

      t.timestamps
    end
  end
end
