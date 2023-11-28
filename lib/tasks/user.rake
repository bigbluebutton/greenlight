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

require_relative 'task_helpers'

namespace :user do
  desc 'Create a user'
  task :create, %i[name email password role] => :environment do |_task, args|
    # Default values.
    user = {
      provider: 'greenlight',
      verified: true,
      status: :active,
      language: I18n.default_locale
    }.merge(args)

    check_role!(user:)
    user = User.new(user)

    display_user_errors(user:) unless user.save

    success 'User account was created successfully!'
    info "  Name: #{user.name}"
    info "  Email: #{user.email}"
    info "  Password: #{user.password}"
    info "  Role: #{user.role.name}"

    exit 0
  end

  desc 'Set user role to Administrator'
  task :set_admin_role, %i[email] => :environment do |_task, args|
    email = args[:email]

    # return err if no user email provided
    err 'Please provide an email address of the user you wish to set to Administrator role.' if email.blank?

    user = User.find_by(email:, provider: 'greenlight')

    # return err if user not found
    err "User with email: #{email} not found" if user.blank?

    role = Role.find_by(name: 'Administrator', provider: 'greenlight')

    # return err if Administrator role not found
    err "Role 'Administrator' not found for provider 'greenlight'" if role.blank?

    user.role = role
    user.save!
    success "User role set to Administrator for email: #{email}"
  end

  private

  def check_role!(user:)
    role_name = user[:role]
    user[:role] = Role.find_by(name: role_name, provider: 'greenlight')
    return if user[:role]

    warning "Unable to create user: '#{user[:name]}'"
    err "   Role '#{role_name}' does not exist, maybe you have not run the DB migrations?"
  end

  def display_user_errors(user:)
    warning "Unable to create user: '#{user.name}'"
    err "   Failed to pass the following validations:\n    #{user.errors.to_a}"
  end
end
