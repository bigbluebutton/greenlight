# frozen_string_literal: true

class AddDeletionPlannedAtToRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :deletion_planned_at, :datetime
  end
end
