# frozen_string_literal: true

class AddOnlineToRoom < ActiveRecord::Migration[7.0]
  def change
    add_column :rooms, :online, :boolean
  end
end
