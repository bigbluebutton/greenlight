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
  has_and_belongs_to_many :users, join_table: :users_roles # Obsolete -- not used anymore
  has_many :role_permissions

  has_many :users

  default_scope { includes(:role_permissions) }
  scope :by_priority, -> { order(:priority) }
  scope :editable_roles, ->(provider) { where(provider: provider).where.not(name: %w[super_admin denied pending]) }

  RESERVED_ROLE_NAMES = %w[super_admin admin pending denied user]

  def self.duplicate_name(name, provider)
    RESERVED_ROLE_NAMES.include?(name) || Role.exists?(name: name, provider: provider)
  end

  def self.create_default_roles(provider)
    Role.create(name: "user", provider: provider, priority: 1, colour: "#868e96")
        .update_all_role_permissions(can_create_rooms: true)
    Role.create(name: "admin", provider: provider, priority: 0, colour: "#f1c40f")
        .update_all_role_permissions(can_create_rooms: true, send_promoted_email: true,
      send_demoted_email: true, can_edit_site_settings: true, can_manage_rooms_recordings: true,
      can_edit_roles: true, can_manage_users: true)
    Role.create(name: "pending", provider: provider, priority: -1, colour: "#17a2b8").update_all_role_permissions
    Role.create(name: "denied", provider: provider, priority: -2, colour: "#343a40").update_all_role_permissions
    Role.create(name: "super_admin", provider: provider, priority: -3, colour: "#cd201f")
        .update_all_role_permissions(can_create_rooms: true,
      send_promoted_email: true, send_demoted_email: true, can_edit_site_settings: true,
      can_edit_roles: true, can_manage_users: true, can_manage_rooms_recordings: true)
  end

  def self.create_new_role(role_name, provider)
    # Create the new role with the second highest priority
    # This means that it will only be more important than the user role
    # This also updates the user role to have the highest priority
    role = Role.create(name: role_name, provider: provider)
    user_role = Role.find_by(name: 'user', provider: provider)

    role.priority = user_role.priority
    user_role.priority += 1

    user_role.save!
    role.save!

    role
  end

  def update_all_role_permissions(permissions = {})
    update_permission("can_create_rooms", permissions[:can_create_rooms].to_s)
    update_permission("send_promoted_email", permissions[:send_promoted_email].to_s)
    update_permission("send_demoted_email", permissions[:send_demoted_email].to_s)
    update_permission("can_edit_site_settings", permissions[:can_edit_site_settings].to_s)
    update_permission("can_edit_roles", permissions[:can_edit_roles].to_s)
    update_permission("can_manage_users", permissions[:can_manage_users].to_s)
    update_permission("can_manage_rooms_recordings", permissions[:can_manage_rooms_recordings].to_s)
    update_permission("can_appear_in_share_list", permissions[:can_appear_in_share_list].to_s)
  end

  # Updates the value of the permission and enables it
  def update_permission(name, value)
    # Dont update if it is not explicitly set to a value
    return unless value.present?

    permission = role_permissions.find_or_create_by!(name: name)

    permission.update_attributes(value: value, enabled: true)
  end

  # Returns the value if enabled or the default if not enabled
  def get_permission(name, return_boolean = true)
    value = nil

    role_permissions.each do |permission|
      next if permission.name != name

      value = if permission.enabled
        permission.value
      else
        default_value(name)
      end
    end

    # Create the role_permissions since it doesn't exist
    role_permissions.create(name: name) if value.nil?

    if return_boolean
      value == "true"
    else
      value
    end
  end

  private

  def default_value(name)
    case name
    when "can_appear_in_share_list"
      Rails.configuration.shared_access_default.to_s
    else
      "false"
    end
  end
end
