# frozen_string_literal: true

class AddTermsAndMarketingToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.boolean :terms, default: false
      t.boolean :marketing, default: false
    end
  end
end
