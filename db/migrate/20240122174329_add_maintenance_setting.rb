# frozen_string_literal: true

class AddMaintenanceSetting < ActiveRecord::Migration[7.1]
  def up
    Setting.create!(name: 'Maintenance') unless Setting.exists?(name: 'Maintenance')

    return if SiteSetting.exists?(setting: Setting.find_by(name: 'Maintenance'))

    SiteSetting.create!(
      setting: Setting.find_by(name: 'Maintenance'),
      value: '',
      provider: 'greenlight'
    )
  end

  def down
    Setting.find_by(name: 'Maintenance')&.destroy
    SiteSetting.find_by(setting: Setting.find_by(name: 'Maintenance')).destroy
  end
end
