# frozen_string_literal: true

class PopulateRoles < ActiveRecord::Migration[7.0]
  def up
    Role.create! [
      { name: 'Administrator' },
      { name: 'User' },
      { name: 'Guest' }
    ]
  end

  def down
    Role.destroy_all
  end
end
