# frozen_string_literal: true

class AddAllowNameUpdateToSiteSettings < ActiveRecord::Migration[7.0]
  def up
    setting = Setting.find_or_create_by(name: 'AllowNameUpdate')

    SiteSetting.create!(setting:, value: 'true', provider: 'greenlight') unless SiteSetting.exists?(setting:, provider: 'greenlight')

    Tenant.find_each do |tenant|
      SiteSetting.create!(setting:, value: 'true', provider: tenant.name) unless SiteSetting.exists?(setting:, provider: tenant.name)
    end
  end

  def down
    Tenant.find_each do |tenant|
      SiteSetting.find_by(setting: Setting.find_by(name: 'AllowNameUpdate'), provider: tenant.name)&.destroy
    end

    SiteSetting.find_by(setting: Setting.find_by(name: 'AllowNameUpdate'), provider: 'greenlight')&.destroy

    Setting.find_by(name: 'AllowNameUpdate')&.destroy
  end
end
