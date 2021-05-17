class AddFirstnameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :firstname, :string
  end
end
