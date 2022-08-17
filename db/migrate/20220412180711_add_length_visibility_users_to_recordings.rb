# frozen_string_literal: true

class AddLengthVisibilityUsersToRecordings < ActiveRecord::Migration[7.0]
  def change
    change_table :recordings, bulk: true do |t|
      t.string :visibility, null: false
      t.integer :length, null: false
      t.integer :participants, null: false
    end
  end
end
