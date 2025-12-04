# frozen_string_literal: true

class UpdateMuteOnStartToEnabled < ActiveRecord::Migration[7.2]
  def up
    meeting_option = MeetingOption.find_by(name: 'muteOnStart')

    RoomsConfiguration.find_by(meeting_option:, value: 'optional', provider: 'greenlight')&.update(value: 'default_enabled')

    Tenant.find_each do |tenant|
      RoomsConfiguration.find_by(meeting_option:, value: 'optional', provider: tenant.name)&.update(value: 'default_enabled')
    end
  end

  def down
    meeting_option = MeetingOption.find_by(name: 'muteOnStart')

    RoomsConfiguration.find_by(meeting_option:, value: 'default_enabled', provider: 'greenlight')&.update(value: 'optional')

    Tenant.find_each do |tenant|
      RoomsConfiguration.find_by(meeting_option:, value: 'default_enabled', provider: tenant.name)&.update(value: 'optional')
    end
  end
end
