class CreateInstantRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :instant_rooms do |t|
      t.string :name
      t.string :username
      t.string :friendly_id, null: false, index: { unique: true }
      t.string :meeting_id, null: false, index: { unique: true }
      t.datetime :last_session
      t.timestamps
    end
  end
end
