# frozen_string_literal: true

class PopulateSettings < ActiveRecord::Migration[7.0]
  def up
    Setting.create! [
      { name: 'PrimaryColor' },
      { name: 'PrimaryColorLight' },
      { name: 'PrimaryColorDark' },
      { name: 'BrandingImage' },
      { name: 'Terms' },
      { name: 'PrivacyPolicy' },
      { name: 'RegistrationMethod' },
      { name: 'ShareRooms' },
      { name: 'PreuploadPresentation' },
      { name: 'RoleMapping' }
    ]
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
