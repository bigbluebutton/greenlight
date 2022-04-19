# frozen_string_literal: true

class CreateMeetingOptions < ActiveRecord::Migration[7.0]
  def change
    create_table :meeting_options do |t|
      t.string :name
      t.string :value

      t.timestamps
    end

    add_index :meeting_options, :name, unique: true
  end
end
