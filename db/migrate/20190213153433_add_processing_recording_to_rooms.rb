# frozen_string_literal: true

class AddProcessingRecordingToRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :recordings_processing, :integer, default: 0
  end
end
