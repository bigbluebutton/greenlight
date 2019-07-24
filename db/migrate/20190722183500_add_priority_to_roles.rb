# frozen_string_literal: true

class AddPriorityToRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :priority, :integer, default: -1
  end
end
