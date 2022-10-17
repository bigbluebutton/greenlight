# frozen_string_literal: true

class AddIndexToRoles < ActiveRecord::Migration[7.0]
  def change
    add_index :roles, %i[name provider], unique: true
  end
end
