class AddHelpCenterSiteSetting < ActiveRecord::Migration[7.1]
  def up
    SiteSetting.create!(
      setting: Setting.find_by(name: 'HelpCenter'),
      value: '',
      provider: 'greenlight'
    ) unless SiteSetting.exists?(setting: Setting.find_by(name: 'HelpCenter'))
  end

  def down
    SiteSetting.find_by(setting: Setting.find_by(name: 'HelpCenter')).destroy
  end
end
