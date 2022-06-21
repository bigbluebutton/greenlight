# frozen_string_literal: true

class AddModeratorAccessCodeToRooms < ActiveRecord::Migration[7.0]
  def change
    add_column :rooms, :moderator_access_code, :string
  end
end
