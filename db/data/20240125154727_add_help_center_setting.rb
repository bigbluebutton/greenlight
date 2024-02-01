# frozen_string_literal: true

class AddHelpCenterSetting < ActiveRecord::Migration[7.1]
  def up
    setting = Setting.find_or_create_by(name: 'HelpCenter')

    SiteSetting.find_or_create_by(setting:, value: '', provider: 'greenlight')

    Tenant.all.each do |tenant|
      SiteSetting.find_or_create_by(setting:, value: '', provider: tenant.name)
    end
  end

  def down
    Setting.find_by(name: 'HelpCenter')&.destroy
    SiteSetting.find_by(setting: Setting.find_by(name: 'HelpCenter')).destroy
  end
end
