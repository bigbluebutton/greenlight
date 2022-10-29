# frozen_string_literal: true

class AddLastPwdUpdateToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :last_pwd_update, :datetime
  end
end
