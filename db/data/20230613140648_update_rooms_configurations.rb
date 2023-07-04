# frozen_string_literal: true

class UpdateRoomsConfigurations < ActiveRecord::Migration[7.0]
  def up
    RoomsConfiguration.create! [
      { meeting_option: MeetingOption.find_by(name: 'logoutURL'), value: 'optional', provider: 'greenlight' }
    ]
  end

  def down
    RoomsConfiguration.destroy_by(meeting_option: MeetingOption.find_by(name: 'logoutURL')).present?
  end
end
