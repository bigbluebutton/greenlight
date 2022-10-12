# frozen_string_literal: true

class PopulateDefaultRoleSettings < ActiveRecord::Migration[7.0]
  def up
    Setting.create! [
      { name: 'DefaultRole' }
    ]

    SiteSetting.create! [
      { setting: Setting.find_by(name: 'DefaultRole'), provider: 'greenlight', value: 'User' }
    ]
  end

  def down
    setting = Setting.find_by(name: 'DefaultRole')
    SiteSetting.where(setting:).destroy_all
    setting.destroy!
  end
end
