# frozen_string_literal: true

class AddTimezoneToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :time_zone, :string
  end
end
