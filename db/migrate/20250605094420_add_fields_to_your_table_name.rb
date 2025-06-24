class AddFieldsToRecordings < ActiveRecord::Migration[7.2]
  def change
    add_column :recordings, :recycle_bin_at, :datetime
    add_column :recordings, :display_name, :string
    add_column :recordings, :folder_path, :string
    add_column :recordings, :downloadable, :boolean
  end
end
