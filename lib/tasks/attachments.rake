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

namespace :attachments do
  desc 'Checks that the application was configured correctly'
  task start: :environment do
    ActiveStorage::Blob.update_all(service_name: 'mirror') # rubocop:disable Rails/SkipsModelValidations
    ActiveStorage::Blob.find_each(&:mirror_later)
    success('Started mirroring process...')
  end

  task :finish, %i[new_service] => :environment do |_task, args|
    ActiveStorage::Blob.update_all(service_name: args[:new_service]) # rubocop:disable Rails/SkipsModelValidations
    success('Finished mirroring process...')
  end
end
