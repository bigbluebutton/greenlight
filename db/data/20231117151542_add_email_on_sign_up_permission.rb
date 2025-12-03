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

class AddEmailOnSignUpPermission < ActiveRecord::Migration[7.1]
  def up
    email_permission = Permission.create!(name: 'EmailOnSignup')
    admin = Role.where(name: 'Administrator')

    values = admin.map do |adm|
      { role: adm, permission: email_permission, value: 'true' }
    end

    Role.where.not(name: 'Administrator').find_each do |role|
      values.push({ role:, permission: email_permission, value: 'false' })
    end

    RolePermission.create! values
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
