# frozen_string_literal: true

class AddModeratorAccessCodeToRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :moderator_access_code, :string, null: true, default: nil
  end
end
