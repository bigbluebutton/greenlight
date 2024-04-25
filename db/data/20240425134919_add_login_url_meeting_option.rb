# frozen_string_literal: true

class AddLoginUrlMeetingOption < ActiveRecord::Migration[7.1]
  def up
    MeetingOption.create! name: 'loginURL', default_value: ''
    RoomsConfiguration.create! meeting_option: MeetingOption.find_by(name: 'loginURL'), value: 'optional', provider: 'greenlight'
  end

  def down
    MeetingOption.destroy_by name: 'loginURL'
  end
end
