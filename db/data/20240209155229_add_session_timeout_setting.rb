# frozen_string_literal: true

class AddSessionTimeoutSetting < ActiveRecord::Migration[7.1]
  def up
    default_value = '1'
    Setting.create!(name: 'SessionTimeout') unless Setting.exists?(name: 'SessionTimeout')

    return if SiteSetting.exists?(setting: Setting.find_by(name: 'SessionTimeout'))

    SiteSetting.create!(
      setting: Setting.find_by(name: 'SessionTimeout'),
      value: default_value,
      provider: 'greenlight'
    )
  end

  def down
    SiteSetting.find_by(setting: Setting.find_by(name: 'SessionTimeout')).destroy
    Setting.find_by(name: 'SessionTimeout')&.destroy
  end
end
