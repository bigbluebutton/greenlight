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

class PopulateMeetingOptions < ActiveRecord::Migration[7.0]
  def up
    MeetingOption.create! [
      # To configure greenlight meetings add new MeetingOption record with the fallowing format
      # { name: #param_name, default_value: #value }
      # where #param_name and #value are respectively the parameter name and value from BBB create API documentation.
      # For a full list check https://docs.bigbluebutton.org/dev/api.html#create:
      #
      # BBB parameters:
      { name: 'record', default_value: 'false' }, # true | false
      { name: 'muteOnStart', default_value: 'false' }, # true | false
      { name: 'guestPolicy', default_value: 'ALWAYS_ACCEPT' }, # ALWAYS_ACCEPT | ALWAYS_DENY | ASK_MODERATOR
      # GL only options:
      { name: 'glAnyoneCanStart', default_value: 'false' }, # true | false
      { name: 'glAnyoneJoinAsModerator', default_value: 'false' }, # true | false
      { name: 'glRequireAuthentication', default_value: 'false' }, # true | false
      { name: 'glModeratorAccessCode', default_value: '' },
      { name: 'glViewerAccessCode', default_value: '' }
    ]
  end

  def down
    MeetingOption.destroy_all
  end
end
