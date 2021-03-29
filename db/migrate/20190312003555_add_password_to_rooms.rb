# frozen_string_literal: true

class AddPasswordToRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :moderator_pw, :string
    add_column :rooms, :attendee_pw, :string
    Room.reset_column_information
    Room.all.each do |room|
      room.update_attributes!(
        moderator_pw: RandomPassword.generate(length: 12),
        attendee_pw: RandomPassword.generate(length: 12)
      )
    end
  end
end
