# frozen_string_literal: true

class AddVoiceBrigeToRomms < ActiveRecord::Migration[7.0]
  def change
    add_column :rooms, :voice_bridge, :integer, null: true, default: nil
    add_index :rooms, :voice_bridge, unique: true
  end
end
