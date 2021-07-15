class AddMonitoringUrlToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :monitoring_url, :string
  end
end
