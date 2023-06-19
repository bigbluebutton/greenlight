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

desc "Add default tenant"
task :add_default_tenant, [:secret] => :environment do |t, args|
  err "Missing secret" unless args.secret

  tenant = Tenant.new(name: "bn", client_secret: args.secret)

  if tenant.save
    TenantSetup.new("bn").call
    success "Tenant created successfully."
  else
    err "Tenant not created. Errors: #{tenant.errors.to_a}"
  end
end
