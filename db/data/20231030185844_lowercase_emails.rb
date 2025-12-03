# frozen_string_literal: true

class LowercaseEmails < ActiveRecord::Migration[7.1]
  def up
    User.find_each(batch_size: 250) do |user|
      downcase = user.email.downcase
      next if user.email == downcase

      user.update(email: downcase)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
