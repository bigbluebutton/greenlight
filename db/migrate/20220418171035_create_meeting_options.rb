# frozen_string_literal: true

class CreateMeetingOptions < ActiveRecord::Migration[7.0]
  def change
    create_table :meeting_options, id: :uuid do |t|
      t.string :name, index: { unique: true }
      t.string :default_value

      t.timestamps
    end
  end
end
