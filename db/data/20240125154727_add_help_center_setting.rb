# frozen_string_literal: true

class AddHelpCenterSetting < ActiveRecord::Migration[7.1]
  def up
    setting = Setting.find_or_create_by(name: 'HelpCenter')

    SiteSetting.create(setting:, value: '', provider: 'greenlight') unless SiteSetting.exists?(setting:, provider: 'greenlight')

    Tenant.all.each do |tenant|
      SiteSetting.create(setting:, value: '', provider: tenant.name) unless SiteSetting.exists?(setting:, provider: tenant.name)
    end
  end

  def down
    Tenant.all.each do |tenant|
      SiteSetting.find_by(setting: Setting.find_by(name: 'HelpCenter'), provider: tenant.name).destroy
    end

    SiteSetting.find_by(setting: Setting.find_by(name: 'HelpCenter'), provider: 'greenlight').destroy

    Setting.find_by(name: 'HelpCenter')&.destroy
  end
end
