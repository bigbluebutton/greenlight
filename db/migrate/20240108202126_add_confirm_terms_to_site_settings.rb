# frozen_string_literal: true

class AddConfirmTermsToSiteSettings < ActiveRecord::Migration[7.1]
  def change
    Setting.create!(name: 'ConfirmTerms') unless Setting.exists?(name: 'ConfirmTerms')

    return if SiteSetting.exists?(setting: Setting.find_by(name: 'ConfirmTerms'))

    SiteSetting.create!(
      setting: Setting.find_by(name: 'ConfirmTerms'),
      value: false,
      provider: 'greenlight'
    )
  end
end
