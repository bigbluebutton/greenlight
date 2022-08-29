# frozen_string_literal: true

class CreateRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms, id: :uuid do |t|
      t.belongs_to :user, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :friendly_id, null: false, index: { unique: true }
      t.string :meeting_id, null: false, index: { unique: true }
      t.datetime :last_session
      t.timestamps
    end
  end
end
