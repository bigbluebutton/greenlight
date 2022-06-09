# frozen_string_literal: true

class AddLangToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users do |t|
      t.string :lang, default: ''
    end
  end
end
