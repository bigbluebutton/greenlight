# frozen_string_literal: true

class AddAccountStatusAttributesToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.boolean :active, default: false
      t.string :activation_digest, index: { unique: true }
      t.datetime :activation_sent_at
    end
  end
end
