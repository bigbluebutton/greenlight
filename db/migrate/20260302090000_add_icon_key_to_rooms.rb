class AddIconKeyToRooms < ActiveRecord::Migration[7.0]
  def change
    add_column :rooms, :icon_key, :string, default: 'general', null: false
    add_index :rooms, :icon_key
  end
end
