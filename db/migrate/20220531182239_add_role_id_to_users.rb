# frozen_string_literal: true

class AddRoleIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :role, foreign_key: true
  end
end
