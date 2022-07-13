# frozen_string_literal: true

class CreateSiteSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :site_settings do |t|
      t.belongs_to :setting, foreign_key: true

      t.string :value, null: false
      t.string :provider, null: false
      t.timestamps
    end
  end
end
