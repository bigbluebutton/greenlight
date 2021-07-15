class AddTwilioToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :twilio, :boolean, default: true
  end
end
