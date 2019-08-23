# frozen_string_literal: true

class AddPasswordDigestToRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :access_code, :string, null: true, default: nil
  end
end
