class AddUniqueIdToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :users, :encrypted_id, :string

    User.all.each do |user|
      user.set_encrypted_id
      user.save!
    end

    change_column_null :users, :encrypted_id, false

    add_index :users, :encrypted_id, unique: true
    remove_index :users, :username
  end

  def down
    add_index :users, :username, unique: true
    remove_index :users, :encrypted_id
    remove_column :users, :encrypted_id
  end
end
