# frozen_string_literal: true

class PopulateRoomsConfigurations < ActiveRecord::Migration[7.0]
  def up
    RoomsConfiguration.create! [
      { meeting_option: MeetingOption.find_by(name: 'record'), value: 'optional', provider: 'greenlight' },
      { meeting_option: MeetingOption.find_by(name: 'muteOnStart'), value: 'optional', provider: 'greenlight' },
      { meeting_option: MeetingOption.find_by(name: 'guestPolicy'), value: 'optional', provider: 'greenlight' },
      { meeting_option: MeetingOption.find_by(name: 'glAnyoneCanStart'), value: 'optional', provider: 'greenlight' },
      { meeting_option: MeetingOption.find_by(name: 'glAnyoneJoinAsModerator'), value: 'optional', provider: 'greenlight' }
    ]
  end

  def down
    RoomsConfiguration.destroy_all
  end
end
