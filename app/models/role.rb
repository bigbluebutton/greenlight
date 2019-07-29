# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
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

class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles

  default_scope { order(:priority) }
  scope :by_priority, -> { order(:priority) }
  scope :editable_roles, ->(provider) { where(provider: provider).where.not(name: %w[super_admin denied pending]) }

  RESERVED_ROLE_NAMES = %w[super_admin admin pending denied user]

  def self.duplicate_name(name, provider)
    RESERVED_ROLE_NAMES.include?(name) || Role.exists?(name: name, provider: provider)
  end

  def self.create_default_roles(provider)
    Role.create(name: "user", provider: provider, priority: 1, can_create_rooms: true)
    Role.create(name: "admin", provider: provider, priority: 0, can_create_rooms: true, send_promoted_email: true,
      send_demoted_email: true, can_edit_site_settings: true,
      can_edit_roles: true, can_manage_users: true,)
    Role.create(name: "pending", provider: provider, priority: -1)
    Role.create(name: "denied", provider: provider, priority: -1)
    Role.create(name: "super_admin", provider: provider, priority: -2, can_create_rooms: true,
      send_promoted_email: true, send_demoted_email: true, can_edit_site_settings: true,
      can_edit_roles: true, can_manage_users: true,)
  end
end
