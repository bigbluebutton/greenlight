# frozen_string_literal: true

class AddResyncOnLoginToSettings < ActiveRecord::Migration[7.0]
  def up
    setting = Setting.create!(name: 'ResyncOnLogin')
    SiteSetting.create!(setting:, value: 'true', provider: 'greenlight')
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
