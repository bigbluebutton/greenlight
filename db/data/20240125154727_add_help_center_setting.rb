# frozen_string_literal: true

class AddHelpCenterSetting < ActiveRecord::Migration[7.1]
  def up
    setting = Setting.create(name: 'HelpCenter') unless Setting.exists?(name: 'HelpCenter')

    SiteSetting.create(setting:, value: '', provider: 'greenlight') unless SiteSetting.exists?(setting:, value: '', provider: 'greenlight')

    Tenant.all.each do |tenant|
      SiteSetting.find_or_create_by(setting:, value: '', provider: tenant.name)
    end
  end

  def down
    Setting.find_by(name: 'HelpCenter')&.destroy
    SiteSetting.find_by(setting: Setting.find_by(name: 'HelpCenter')).destroy
  end
end
