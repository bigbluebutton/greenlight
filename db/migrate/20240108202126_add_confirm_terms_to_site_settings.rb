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

    change_table :users, bulk: true do |t|
      t.boolean :confirm_terms, default: false
      t.boolean :email_notifs, default: false
    end
  end
end
