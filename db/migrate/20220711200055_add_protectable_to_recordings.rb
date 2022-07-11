# frozen_string_literal: true

class AddProtectableToRecordings < ActiveRecord::Migration[7.0]
  def change
    add_column :recordings, :protectable, :boolean
  end
end
