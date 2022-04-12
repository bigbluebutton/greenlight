# frozen_string_literal: true

class AddVisibilityToRecordings < ActiveRecord::Migration[7.0]
  def change
    add_column :recordings, :visibility, :string
  end
end
