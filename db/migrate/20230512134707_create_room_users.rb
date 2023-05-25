class CreateRoomUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :room_users, id: false do |t|
      t.belongs_to :room, foreign_key: { on_delete: :cascade }, type: :uuid
      t.belongs_to :user, foreign_key: { on_delete: :cascade }, type: :uuid

      t.uuid :event_id
    end

    add_index :room_users, %i[room_id user_id event_id], unique: true
  end
end
