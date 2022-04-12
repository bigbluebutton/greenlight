# frozen_string_literal: true

class AddLengthToRecordings < ActiveRecord::Migration[7.0]
  def change
    add_column :recordings, :length, :integer
  end
end
