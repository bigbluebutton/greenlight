# frozen_string_literal: true

class AddResetPwdAttributesToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :reset_digest
      t.datetime :reset_sent_at
    end
  end
end
