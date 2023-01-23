# frozen_string_literal: true

class UpdateRecordRoomsConfigurationDefault < ActiveRecord::Migration[7.0]
  def up
    RoomsConfiguration.find_by(meeting_option: MeetingOption.find_by(name: 'record'), provider: 'greenlight').update(value: 'default')
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
