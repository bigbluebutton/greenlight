# frozen_string_literal: true

class AddRoomSettingsToRoom < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :room_settings, :string, default: "{ }"
  end
end
