# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

# rubocop:disable Rails/ReversibleMigration
class ChangeTenantIdTypeToUuid < ActiveRecord::Migration[7.0]
  def change
    add_column :tenants, :uuid, :uuid, default: 'gen_random_uuid()', null: false

    change_table :tenants do |t|
      t.remove :id
      t.rename :uuid, :id # rubocop:disable Rails/DangerousColumnNames
    end
    execute 'ALTER TABLE tenants ADD PRIMARY KEY (id);'
  end
end
# rubocop:enable Rails/ReversibleMigration
