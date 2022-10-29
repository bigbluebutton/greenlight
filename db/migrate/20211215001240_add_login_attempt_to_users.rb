# frozen_string_literal: true

class AddLoginAttemptToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :failed_attempts, :integer
    add_column :users, :last_failed_attempt, :datetime
  end
end
