class CreateMeetings < ActiveRecord::Migration[5.0]
  def change
    create_table :meetings do |t|
      t.belongs_to :room, index: true
      t.string :name, index: true
      t.string :uid, index: true

      t.timestamps
    end
  end
end
