# frozen_string_literal: true

class AddDefaultRecordingVisibilityToSettings < ActiveRecord::Migration[7.1]
  def up
    setting = Setting.create!(name: 'DefaultRecordingVisibility')
    SiteSetting.create!(setting:, value: 'Published', provider: 'greenlight')
    Tenant.each do |tenant|
      SiteSetting.create!(setting:, value: 'Published', provider: tenant.name)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
