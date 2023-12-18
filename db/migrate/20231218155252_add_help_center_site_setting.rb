# frozen_string_literal: true

class AddHelpCenterSiteSetting < ActiveRecord::Migration[7.1]
  def up
    return if SiteSetting.exists?(setting: Setting.find_by(name: 'HelpCenter'))

    SiteSetting.create!(
      setting: Setting.find_by(name: 'HelpCenter'),
      value: '',
      provider: 'greenlight'
    )
  end

  def down
    SiteSetting.find_by(setting: Setting.find_by(name: 'HelpCenter')).destroy
  end
end
