# frozen_string_literal: true

class AddLanguageToUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users do |t|
      t.string :language, null: false
    end
  end
end
