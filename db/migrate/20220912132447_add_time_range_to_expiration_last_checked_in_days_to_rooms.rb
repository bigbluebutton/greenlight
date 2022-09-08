# frozen_string_literal: true

class AddTimeRangeToExpirationLastCheckedInDaysToRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :time_range_to_expiration_last_checked_in_days, :integer
  end
end
