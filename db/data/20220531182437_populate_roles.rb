# frozen_string_literal: true

class PopulateRoles < ActiveRecord::Migration[7.0]
  def up
    Role.create! [
      { name: 'Administrator', provider: 'greenlight' },
      { name: 'User', provider: 'greenlight' },
      { name: 'Guest', provider: 'greenlight' }
    ]
  end

  def down
    Role.destroy_all
  end
end
