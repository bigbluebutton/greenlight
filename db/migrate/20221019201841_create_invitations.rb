# frozen_string_literal: true

class CreateInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :invitations do |t|
      t.string 'email', null: false
      t.string 'provider', null: false
      t.string 'token', null: false, index: { unique: true }
      t.timestamps
    end

    add_index :invitations, %i[email provider], unique: true
  end
end
