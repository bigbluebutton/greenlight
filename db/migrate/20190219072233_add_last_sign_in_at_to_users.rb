class AddLastSignInAtToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_sign_in_at, :datetime
  end
end
