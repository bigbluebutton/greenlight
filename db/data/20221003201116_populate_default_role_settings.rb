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
    Setting.find_by(name: 'DefaultRole').delete
    SiteSetting.find_by(setting: Setting.find_by(name: 'DefaultRole').delete)
  end
end
