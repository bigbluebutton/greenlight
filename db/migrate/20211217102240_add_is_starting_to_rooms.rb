# frozen_string_literal: true

class AddIsStartingToRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :is_starting, :boolean, null: false, default: false
  end
end
