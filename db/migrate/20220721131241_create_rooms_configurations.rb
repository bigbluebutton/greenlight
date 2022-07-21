# frozen_string_literal: true

class CreateRoomsConfigurations < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms_configurations do |t|
      t.belongs_to :meeting_option, foreign_key: true
      t.string :provider, null: false
      t.string :value, null: false
      t.timestamps
    end

    add_index :rooms_configurations, %i[meeting_option_id provider], unique: true
  end
end
