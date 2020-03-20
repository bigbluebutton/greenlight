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

module Rolify
  extend ActiveSupport::Concern

  # Gets all roles
  def all_roles(selected_role)
    @roles = Role.editable_roles(@user_domain)

    if @roles.count.zero?
      Role.create_default_roles(@user_domain)
      @roles = Role.editable_roles(@user_domain)
    end

    @selected_role = if selected_role.nil?
      @roles.find_by(name: 'user')
    else
      @roles.find(selected_role)
    end

    @roles
  end

  # Creates a new role
  def create_role(new_role_name)
    # Make sure that the role name isn't a duplicate or a reserved name like super_admin or empty
    return nil if Role.duplicate_name(new_role_name, @user_domain) || new_role_name.strip.empty?

    Role.create_new_role(new_role_name, @user_domain)
  end

  # Updates a user's roles
  def update_roles(roles)
    # Check that the user can manage users
    return true unless current_user.highest_priority_role.get_permission("can_manage_users")

    new_roles = roles.split(' ').map(&:to_i)
    old_roles = @user.roles.pluck(:id).uniq

    added_role_ids = new_roles - old_roles
    removed_role_ids = old_roles - new_roles

    added_roles = []
    removed_roles = []
    current_user_role = current_user.highest_priority_role

    # Check that the user has the permissions to add all the new roles
    added_role_ids.each do |id|
      role = Role.find(id)

      # Admins are able to add the admin role to other users. All other roles may only
      # add roles with a higher priority
      if (role.priority > current_user_role.priority || current_user_role.name == "admin") &&
         role.provider == @user_domain
        added_roles << role
      else
        return false
      end
    end

    # Check that the user has the permissions to remove all the deleted roles
    removed_role_ids.each do |id|
      role = Role.find(id)

      # Admins are able to remove the admin role from other users. All other roles may only
      # remove roles with a higher priority
      if (role.priority > current_user_role.priority || current_user_role.name == "admin") &&
         role.provider == @user_domain
        removed_roles << role
      else
        return false
      end
    end

    # Send promoted/demoted emails
    added_roles.each { |role| send_user_promoted_email(@user, role) if role.get_permission("send_promoted_email") }
    removed_roles.each { |role| send_user_demoted_email(@user, role) if role.get_permission("send_demoted_email") }

    # Update the roles
    @user.roles.delete(removed_roles)
    @user.roles << added_roles

    # Make sure each user always has at least the user role
    @user.roles = [Role.find_by(name: "user", provider: @user_domain)] if @user.roles.count.zero?

    @user.save!
  end

  # Updates a roles priority
  def update_priority(role_to_update)
    user_role = Role.find_by(name: "user", provider: @user_domain)
    admin_role = Role.find_by(name: "admin", provider: @user_domain)

    current_user_role = current_user.highest_priority_role

    # Users aren't allowed to update the priority of the admin or user roles
    return false if role_to_update.include?(user_role.id.to_s) || role_to_update.include?(admin_role.id.to_s)

    # Restrict users to only updating the priority for roles in their domain with a higher
    # priority
    role_to_update.each do |id|
      role = Role.find(id)
      return false if role.priority <= current_user_role.priority || role.provider != @user_domain
    end

    # Get the priority of the current user's role and start with 1 higher
    new_priority = [current_user_role.priority, 0].max + 1

    begin
      # Save the old priorities incase something fails
      old_priority = Role.where(id: role_to_update).select(:id, :priority).index_by(&:id)

      # Set all the priorities to nil to avoid unique column issues
      Role.where(id: role_to_update).update_all(priority: nil)

      # Starting at the starting priority, increase by 1 every time
      role_to_update.each_with_index do |id, index|
        Role.find(id).update_attribute(:priority, new_priority + index)
      end

      true
    rescue => e
      # Reset to old prorities
      role_to_update.each_with_index do |id, _index|
        Role.find(id).update_attribute(:priority, old_priority[id.to_i].priority)
      end

      logger.error "#{current_user} failed to update role priorities: #{e}"

      false
    end
  end

  # Update Permissions
  def update_permissions(role)
    current_user_role = current_user.highest_priority_role

    # Checks that it is valid for the provider to update the role
    return false if role.priority <= current_user_role.priority || role.provider != @user_domain

    role_params = params.require(:role).permit(:name)
    permission_params = params.require(:role).permit(:can_create_rooms, :send_promoted_email,
      :send_demoted_email, :can_edit_site_settings, :can_edit_roles, :can_manage_users,
      :can_manage_rooms_recordings, :can_appear_in_share_list, :colour)

    permission_params.transform_values! do |v|
      if v == "0"
        "false"
      elsif v == "1"
        "true"
      else
        v
      end
    end

    # Role is a default role so users can't change the name
    role_params[:name] = role.name if Role::RESERVED_ROLE_NAMES.include?(role.name)

    # Make sure if the user is updating the role name that the role name is valid
    if role.name != role_params[:name] && !Role.duplicate_name(role_params[:name], @user_domain) &&
       !role_params[:name].strip.empty?
      role.name = role_params[:name]
    elsif role.name != role_params[:name]
      return false
    end

    role.update(colour: permission_params[:colour])
    role.update_all_role_permissions(permission_params)

    role.save!
  end
end
