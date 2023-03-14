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
  include ActionView::Helpers::AssetUrlHelper

  desc 'Send a reset password email to users'
  task :reset_password_email, %i[provider start stop base_url] => :environment do |_task, args|
    args.with_defaults(provider: 'greenlight')
    start, stop = range(args)

    root_url = "#{args[:base_url]}/"

    User.where(external_id: nil, provider: args[:provider])
        .find_each do |user|
      token = user.generate_reset_token!

      UserMailer.with(user:,
                      reset_url: reset_password_url(root_url, token),
                      base_url: args[:base_url],
                      provider: args[:provider]).reset_password_email.deliver_later

      success "Sent reset password email to #{user.email}"
    end

  end

  private

  def range(args)
    start = args[:start].to_i
    start = 1 unless start.positive?

    stop = args[:stop].to_i
    stop = nil unless stop.positive?

    raise red "Unable to migrate: Invalid provided range [start: #{start}, stop: #{stop}]" if stop && start > stop

    [start, stop]
  end

  def reset_password_url(root_url, token)
    "#{root_url}reset_password/#{token}"
  end
end
