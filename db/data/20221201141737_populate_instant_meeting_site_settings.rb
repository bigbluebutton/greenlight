class PopulateInstantMeetingSiteSettings < ActiveRecord::Migration[7.0]
  def up
    Setting.create!(name: 'InstantMeeting')
    SiteSetting.create!(setting: Setting.find_by(name: 'InstantMeeting'), value: 'false', provider: 'greenlight')
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
