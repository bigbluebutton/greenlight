class CreateRooms < ActiveRecord::Migration[5.0]
  def change
    create_table :rooms do |t|
      t.belongs_to :user, index: true
      t.string :uid, index: true

      t.timestamps
    end
  end
end
