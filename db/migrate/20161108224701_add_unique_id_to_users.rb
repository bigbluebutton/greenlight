# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2016 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

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
