# frozen_string_literal: true

class AddHelpCenterSetting < ActiveRecord::Migration[7.1]
  def up
    Setting.create!(name: 'HelpCenter') unless Setting.exists?(name: 'HelpCenter')
  end

  def down
    Setting.find_by(name: 'HelpCenter')&.destroy
  end
end
