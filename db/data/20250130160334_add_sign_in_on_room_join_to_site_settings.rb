# frozen_string_literal: true

class AddSignInOnRoomJoinToSiteSettings < ActiveRecord::Migration[7.1]
  def up
    setting = Setting.find_or_create_by(name: 'SignInOnRoomJoin')

    SiteSetting.create!(setting:, value: 'true', provider: 'greenlight') unless SiteSetting.exists?(setting:, provider: 'greenlight')

    Tenant.find_each do |tenant|
      SiteSetting.create!(setting:, value: 'true', provider: tenant.name) unless SiteSetting.exists?(setting:, provider: tenant.name)
    end
  end

  def down
    Tenant.find_each do |tenant|
      SiteSetting.find_by(setting: Setting.find_by(name: 'SignInOnRoomJoin'), provider: tenant.name)&.destroy
    end

    SiteSetting.find_by(setting: Setting.find_by(name: 'SignInOnRoomJoin'), provider: 'greenlight')&.destroy

    Setting.find_by(name: 'SignInOnRoomJoin')&.destroy
  end
end
