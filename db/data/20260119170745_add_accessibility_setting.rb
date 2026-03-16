# frozen_string_literal: true

class AddAccessibilitySetting < ActiveRecord::Migration[7.2]
  def up
    setting = Setting.find_or_create_by(name: 'AccessibilityStatement')

    SiteSetting.create!(setting:, value: '', provider: 'greenlight') unless SiteSetting.exists?(setting:, provider: 'greenlight')

    Tenant.find_each do |tenant|
      SiteSetting.create!(setting:, value: '', provider: tenant.name) unless SiteSetting.exists?(setting:, provider: tenant.name)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
