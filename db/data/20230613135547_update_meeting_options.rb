# frozen_string_literal: true

class UpdateMeetingOptions < ActiveRecord::Migration[7.0]
  def up
    MeetingOption.create! [
      # BBB parameters:
      { name: 'logoutURL', default_value: '' }
    ]
  end

  def down
    MeetingOption.destroy_by(name: 'logoutURL').present?
  end
end
