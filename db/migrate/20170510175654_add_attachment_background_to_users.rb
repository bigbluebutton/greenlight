class AddAttachmentBackgroundToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.attachment :background
    end
  end

  def self.down
    remove_attachment :users, :background
  end
end
