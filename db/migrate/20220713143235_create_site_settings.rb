# frozen_string_literal: true

class CreateSiteSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :site_settings, id: :uuid do |t|
      t.belongs_to :setting, foreign_key: true, type: :uuid

      t.string :value, null: false
      t.string :provider, null: false
      t.timestamps
    end
  end
end
