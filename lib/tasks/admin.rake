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

namespace :admin do
  desc 'Create an administrator account'
  task :create, %i[name email password] => :environment do |_task, args|
    # Default values.
    admin = {
      name: 'Administrator',
      email: 'admin@example.com',
      password: 'Administrator1!'
    }.merge(args)

    Rake::Task['user:create'].invoke(admin[:name], admin[:email], admin[:password], 'Administrator')

    exit 0
  end

  desc 'Create an super admin account'
  task :super_admin, %i[name email password] => :environment do |_task, args|
    super_admin_email = "superadmin-#{args[:email]}"

    user = User.new(
      name: args[:name],
      email: super_admin_email,
      password: args[:password],
      role: Role.find_by(name: 'SuperAdmin', provider: 'bn'),
      provider: 'bn',
      verified: true,
      status: :active,
      language: I18n.default_locale
    )

    if user.save
      success 'User account was created successfully!'
      info "  Name: #{user.name}"
      info "  Email: #{user.email}"
      info "  Password: #{user.password}"
      info "  Role: #{user.role.name}"
    else
      warning 'There was an error creating this user'
      err "  Error: #{user.errors.full_messages}"
    end

    exit 0
  end
end
