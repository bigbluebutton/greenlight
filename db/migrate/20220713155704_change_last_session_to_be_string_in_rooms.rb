class ChangeLastSessionToBeStringInRooms < ActiveRecord::Migration[7.0]
  def up
    change_column :rooms, :last_session, :string
  end

  def down
    change_column :rooms, :last_session, :datetime
  end
end
