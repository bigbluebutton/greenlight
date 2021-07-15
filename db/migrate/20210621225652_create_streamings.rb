class CreateStreamings < ActiveRecord::Migration[5.2]
  def change
    create_table :streamings do |t|
      t.string :url
      t.string :meeting_id

      t.timestamps
    end
  end
end
