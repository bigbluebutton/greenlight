class CreateRecordings < ActiveRecord::Migration[7.0]
  def change
    create_table :recordings do |t|
      t.belongs_to :room, foreign_key: true

      t.string :name, null: false
      t.string :record_id, null: false

      t.timestamps
    end
  end
end
