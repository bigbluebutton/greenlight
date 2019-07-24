# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Rake::Task['admin:create'].invoke

# Setup the base role priority
tmp_user = User.create
tmp_user.add_role(:admin)
tmp_user.add_role(:user)
tmp_user.add_role(:super_admin)
tmp_user.add_role(:denied)
tmp_user.add_role(:pending)

admin_role = Role.find_by(name: 'admin')
admin_role.priority = 0

if admin_role.role_permission.nil?
    admin_role.create_role_permission(can_create_rooms: true, send_promoted_email: true,
        send_demoted_email: true, administrator_role: true, can_edit_site_settings: true,
        can_edit_roles: true, can_manage_users: true)
else
    admin_role.role_permission.update(can_create_rooms: true, send_promoted_email: true,
        send_demoted_email: true, administrator_role: true, can_edit_site_settings: true,
        can_edit_roles: true, can_manage_users: true)
end

admin_role.save!

user_role = Role.find_by(name: 'user')
user_role.priority = 1

if admin_role.role_permission.nil?
    user_role.create_role_permission(can_create_rooms: true)
else
    user_role.role_permission.update(can_create_rooms: true)
end

user_role.save!
