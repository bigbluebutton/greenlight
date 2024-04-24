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
    MeetingOption.create(name: 'serverTag', default_value: '') unless MeetingOption.exists?(name: 'serverTag')
    unless RoomsConfiguration.exists?(meeting_option: MeetingOption.find_by(name: 'serverTag'), provider: 'greenlight')
      RoomsConfiguration.create(meeting_option: MeetingOption.find_by(name: 'serverTag'), value: 'optional', provider: 'greenlight')
    end
    Tenant.all.each do |tenant|
      unless RoomsConfiguration.exists?(meeting_option: MeetingOption.find_by(name: 'serverTag'), provider: tenant.name)
        RoomsConfiguration.create(meeting_option: MeetingOption.find_by(name: 'serverTag'), value: 'optional', provider: tenant.name)
      end
    end

    MeetingOption.create(name: 'serverTagRequired', default_value: 'false') unless MeetingOption.exists?(name: 'serverTagRequired')
    unless RoomsConfiguration.exists?(meeting_option: MeetingOption.find_by(name: 'serverTagRequired'), provider: 'greenlight')
      RoomsConfiguration.create(meeting_option: MeetingOption.find_by(name: 'serverTagRequired'), value: 'optional', provider: 'greenlight')
    end
    Tenant.all.each do |tenant|
      unless RoomsConfiguration.exists?(meeting_option: MeetingOption.find_by(name: 'serverTagRequired'), provider: tenant.name)
        RoomsConfiguration.create(meeting_option: MeetingOption.find_by(name: 'serverTagRequired'), value: 'optional', provider: tenant.name)
      end
    end
  end

  def down
    Tenant.all.each do |tenant|
      RoomsConfiguration.find_by(meeting_option: MeetingOption.find_by(name: 'serverTag'), provider: tenant.name).destroy
    end
    RoomsConfiguration.find_by(meeting_option: MeetingOption.find_by(name: 'serverTag'), provider: 'greenlight').destroy
    MeetingOption.find_by(name: 'serverTag').destroy

    Tenant.all.each do |tenant|
      RoomsConfiguration.find_by(meeting_option: MeetingOption.find_by(name: 'serverTagRequired'), provider: tenant.name).destroy
    end
    RoomsConfiguration.find_by(meeting_option: MeetingOption.find_by(name: 'serverTagRequired'), provider: 'greenlight').destroy
    MeetingOption.find_by(name: 'serverTagRequired').destroy
  end
end
