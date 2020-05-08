class CreateRecordingStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :recording_statuses do |t|
      t.string :record_id
      t.boolean :available, default: false

      t.timestamps
    end
  end
end
