# frozen_string_literal: true

class CreateSharedAccesses < ActiveRecord::Migration[5.2]
  def change
    create_table :shared_accesses do |t|
      t.belongs_to :room, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
