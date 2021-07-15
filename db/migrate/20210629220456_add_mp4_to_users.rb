class AddMp4ToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :mp4, :boolean, default: true
  end
end
