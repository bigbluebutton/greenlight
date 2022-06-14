# frozen_string_literal: true

class AddAccessCodeToRooms < ActiveRecord::Migration[7.0]
  def change
    add_column :rooms, :access_code, :string
  end
end
