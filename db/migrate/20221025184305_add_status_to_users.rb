# frozen_string_literal: true

class AddStatusToUsers < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :active, :verified
    rename_column :users, :activation_digest, :verification_digest
    rename_column :users, :activation_sent_at, :verification_sent_at
    add_column :users, :status, :integer, default: 0
  end
end
