# frozen_string_literal: true

class AddSessionTimeoutSetting < ActiveRecord::Migration[7.1]
  def up
    default_value = '1'
    setting = Setting.find_or_create_by(name: 'SessionTimeout')

    SiteSetting.create!(setting:, value: default_value, provider: 'greenlight') unless SiteSetting.exists?(setting:, provider: 'greenlight')

    Tenant.find_each do |tenant|
      SiteSetting.create!(setting:, value: default_value, provider: tenant.name) unless SiteSetting.exists?(setting:, provider: tenant.name)
    end
  end

  def down
    Tenant.find_each do |tenant|
      SiteSetting.find_by(setting: Setting.find_by(name: 'SessionTimeout'), provider: tenant.name)&.destroy
    end

    SiteSetting.find_by(setting: Setting.find_by(name: 'SessionTimeout'), provider: 'greenlight')&.destroy

    Setting.find_by(name: 'SessionTimeout')&.destroy
  end
end
