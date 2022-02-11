# frozen_string_literal: true

class RemoveSecurePasswordFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :secure_password, :boolean, null: false, default: false
  end
end
