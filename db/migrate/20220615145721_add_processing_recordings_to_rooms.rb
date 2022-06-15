# frozen_string_literal: true

class AddProcessingRecordingsToRooms < ActiveRecord::Migration[7.0]
  def change
    change_table :rooms do |t|
      t.integer :recordings_processing, default: 0
    end
  end
end
