# frozen_string_literal: true

class AddUsersToRecordings < ActiveRecord::Migration[7.0]
  def change
    add_column :recordings, :users, :integer
  end
end
