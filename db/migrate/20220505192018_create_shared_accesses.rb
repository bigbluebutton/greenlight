# frozen_string_literal: true

class CreateSharedAccesses < ActiveRecord::Migration[7.0]
  def change
    create_table :shared_accesses, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :room, null: false, foreign_key: true, type: :uuid

      t.index %i[user_id room_id], unique: true

      t.timestamps
    end
  end
end
