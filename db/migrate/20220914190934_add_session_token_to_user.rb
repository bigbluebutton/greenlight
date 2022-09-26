# frozen_string_literal: true

class AddSessionTokenToUser < ActiveRecord::Migration[7.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :session_token, index: { unique: true }
      t.datetime :session_expiry
    end
  end
end
