# frozen_string_literal: true

class CreateRoomMeetingOptions < ActiveRecord::Migration[7.0]
  def change
    create_table :room_meeting_options do |t|
      t.belongs_to :room, foreign_key: true
      t.belongs_to :meeting_option, foreign_key: true

      t.string :value
      t.timestamps
    end
  end
end
