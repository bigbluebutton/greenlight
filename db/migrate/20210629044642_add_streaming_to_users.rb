class AddStreamingToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :streaming, :boolean, default: true
  end
end
