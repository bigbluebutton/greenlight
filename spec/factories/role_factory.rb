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

FactoryBot.define do
  factory :role do
    name { Faker::Job.unique.title }
    provider { 'greenlight' }

    after(:create) do |role|
      perm = Permission.find_or_create_by(name: 'CreateRoom')
      perm2 = Permission.find_or_create_by(name: 'RoomLimit')
      perm3 = Permission.find_or_create_by(name: 'SharedList')
      perm4 = Permission.find_or_create_by(name: 'AccessToVisibilities')
      RolePermission.find_or_create_by(permission: perm, role:, value: 'true')
      RolePermission.find_or_create_by(permission: perm2, role:, value: '100')
      RolePermission.find_or_create_by(permission: perm3, role:, value: 'true')
      RolePermission.find_or_create_by(permission: perm4, role:, value: Recording::VISIBILITIES.values)
    end

    trait :with_super_admin do
      name { 'SuperAdmin' }
      provider { 'bn' }
    end
  end
end
