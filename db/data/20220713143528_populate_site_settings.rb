# frozen_string_literal: true

class PopulateSiteSettings < ActiveRecord::Migration[7.0]
  def up
    SiteSetting.create! [
      { setting: Setting.find_by(name: 'PrimaryColor'), value: '#467fcf', provider: 'greenlight' },
      { setting: Setting.find_by(name: 'PrimaryColorLight'), value: '#e8eff9', provider: 'greenlight' },
      { setting: Setting.find_by(name: 'PrimaryColorDark'), value: '#316cbe', provider: 'greenlight' },
      { setting: Setting.find_by(name: 'BrandingImage'),
        value: ActionController::Base.helpers.image_path('bbb_logo.png'),
        provider: 'greenlight' },
      { setting: Setting.find_by(name: 'Terms'), value: '', provider: 'greenlight' },
      { setting: Setting.find_by(name: 'PrivacyPolicy'), value: '', provider: 'greenlight' },
      { setting: Setting.find_by(name: 'RegistrationMethod'), value: SiteSetting::REGISTRATION_METHODS[:open], provider: 'greenlight' },
      { setting: Setting.find_by(name: 'ShareRooms'), value: 'true', provider: 'greenlight' },
      { setting: Setting.find_by(name: 'PreuploadPresentation'), value: 'true', provider: 'greenlight' },
      { setting: Setting.find_by(name: 'RoleMapping'), value: '', provider: 'greenlight' }
    ]
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
