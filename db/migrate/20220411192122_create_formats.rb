# frozen_string_literal: true

class CreateFormats < ActiveRecord::Migration[7.0]
  def change
    create_table :formats, id: :uuid do |t|
      t.belongs_to :recording, foreign_key: true, type: :uuid
      t.string :recording_type, null: false
      t.string :url, null: false

      t.timestamps
    end
  end
end
