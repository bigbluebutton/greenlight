# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :external_id
      t.string :provider, null: false
      t.string :password_digest
      t.datetime :last_login
      t.timestamps
    end

    add_index :users, %i[email provider], unique: true
  end
end
