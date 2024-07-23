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
    MeetingOption.create!(name: 'serverTag', default_value: '') unless MeetingOption.exists?(name: 'serverTag')
    tag_option = MeetingOption.find_by!(name: 'serverTag')
    MeetingOption.create!(name: 'serverTagRequired', default_value: 'false') unless MeetingOption.exists?(name: 'serverTagRequired')
    tag_required_option = MeetingOption.find_by!(name: 'serverTagRequired')

    unless RoomsConfiguration.exists?(meeting_option: tag_option, provider: 'greenlight')
      RoomsConfiguration.create!(meeting_option: tag_option, value: 'optional', provider: 'greenlight')
    end
    unless RoomsConfiguration.exists?(meeting_option: tag_required_option, provider: 'greenlight')
      RoomsConfiguration.create!(meeting_option: tag_required_option, value: 'optional', provider: 'greenlight')
    end
    Tenant.all.each do |tenant|
      unless RoomsConfiguration.exists?(meeting_option: tag_option, provider: tenant.name)
        RoomsConfiguration.create!(meeting_option: tag_option, value: 'optional', provider: tenant.name)
      end
      unless RoomsConfiguration.exists?(meeting_option: tag_required_option, provider: tenant.name)
        RoomsConfiguration.create!(meeting_option: tag_required_option, value: 'optional', provider: tenant.name)
      end
    end

    Room.find_each(batch_size: 250) do |room|
      RoomMeetingOption.find_or_create_by!(room:, meeting_option: tag_option)
      unless RoomMeetingOption.exists?(room:, meeting_option: tag_required_option)
        RoomMeetingOption.create!(room:, meeting_option: tag_required_option, value: 'false')
      end
    end
  end

  def down
    tag_option = MeetingOption.find_by!(name: 'serverTag')
    RoomMeetingOption.destroy_by(meeting_option: tag_option)
    RoomsConfiguration.destroy_by(meeting_option: tag_option)
    tag_option.destroy

    tag_required_option = MeetingOption.find_by!(name: 'serverTagRequired')
    RoomMeetingOption.destroy_by(meeting_option: tag_required_option)
    RoomsConfiguration.destroy_by(meeting_option: tag_required_option)
    tag_required_option.destroy
  end
end
