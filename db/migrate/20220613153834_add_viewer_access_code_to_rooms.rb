# frozen_string_literal: true

class AddViewerAccessCodeToRooms < ActiveRecord::Migration[7.0]
  def change
    add_column :rooms, :viewer_access_code, :string
  end
end
