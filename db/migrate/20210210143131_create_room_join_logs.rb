class CreateRoomJoinLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :room_join_logs do |t|
      t.references :room
      t.string :username
      t.string :ip_address
      t.timestamps
    end
  end
end
