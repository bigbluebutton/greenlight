# frozen_string_literal: true

class CreateInvitations < ActiveRecord::Migration[5.0]
  def change
    create_table :invitations do |t|
      t.string "email", null: false
      t.string "provider", null: false
      t.string "invite_token"
      t.timestamps
    end
  end
end
