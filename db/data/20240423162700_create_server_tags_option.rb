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

class CreateServerTagsOption < ActiveRecord::Migration[7.0]
  def up
    MeetingOption.create(name: 'meta_server-tag', default_value: '') unless MeetingOption.exists?(name: 'meta_server-tag')
    unless RoomsConfiguration.exists?(meeting_option: MeetingOption.find_by(name: 'meta_server-tag'), provider: 'greenlight')
      RoomsConfiguration.create(meeting_option: MeetingOption.find_by(name: 'meta_server-tag'), value: 'optional', provider: 'greenlight')
    end
    Tenant.all.each do |tenant|
      unless RoomsConfiguration.exists?(meeting_option: MeetingOption.find_by(name: 'meta_server-tag'), provider: tenant.name)
        RoomsConfiguration.create(meeting_option: MeetingOption.find_by(name: 'meta_server-tag'), value: 'optional', provider: tenant.name)
      end
    end
  end

  def down
    Tenant.all.each do |tenant|
      RoomsConfiguration.find_by(meeting_option: MeetingOption.find_by(name: 'meta_server-tag'), provider: tenant.name).destroy
    end
    RoomsConfiguration.find_by(meeting_option: MeetingOption.find_by(name: 'meta_server-tag'), provider: 'greenlight').destroy
    MeetingOption.find_by(name: 'meta_server-tag').destroy
  end
end
