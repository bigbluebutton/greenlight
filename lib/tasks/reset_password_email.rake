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

namespace :migration do
  BATCH_SIZE = 500

  desc 'Send a reset password email to users'
  task :reset_password_email, %i[base_url provider] => :environment do |_task, args|
    args.with_defaults(provider: 'greenlight')

    root_url = "#{args[:base_url]}/"

    # After the migration, all the users except those with an external_id will need to reset their password
    User.where(external_id: nil, provider: args[:provider])
        .find_each(batch_size: BATCH_SIZE) do |user|
      token = user.generate_reset_token!

      UserMailer.with(user:,
                      reset_url: reset_password_url(root_url, token),
                      base_url: args[:base_url],
                      provider: args[:provider]).reset_password_email.deliver_later

      success "Sent reset password email to #{user.email}"
    end
  end

  private

  def reset_password_url(root_url, token)
    "#{root_url}reset_password/#{token}"
  end
end
