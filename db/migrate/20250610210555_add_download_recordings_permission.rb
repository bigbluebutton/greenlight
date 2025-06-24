class AddDownloadRecordingsPermission < ActiveRecord::Migration[7.2]
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          INSERT INTO permissions (name, description, created_at, updated_at)
          VALUES ('download_recordings', 'Allows user to download recordings', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
          ON CONFLICT (name) DO NOTHING;
        SQL
      end

      dir.down do
        execute <<-SQL
          DELETE FROM permissions WHERE name = 'download_recordings';
        SQL
      end
    end
  end
end

