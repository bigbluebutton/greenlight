# frozen_string_literal: true

class RenameTypeToRecordingType < ActiveRecord::Migration[7.0]
  def change
    rename_column :formats, :type, :recording_type
  end
end
