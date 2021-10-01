# frozen_string_literal: true

class AddLastLoginToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :last_login, :datetime
  end
end
