# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2016 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

class RecordingUpdatesJob < ApplicationJob
  include BbbApi

  queue_as :default

  def perform(room, record_id)
    recording = bbb_get_recordings({recordID: record_id})[:recordings].first
    full_id = "#{room}-#{recording[:metadata][:"meeting-name"]}"

    change = (recording[:metadata][:"gl-listed"] == "true") ? I18n.t('slack.published') : I18n.t('slack.unpublished')
    slack_message = I18n.t('slack.recording_visibility', meeting: recording[:metadata][:"meeting-name"], change: change)
    Rails.application.config.slack_notifier.ping slack_message if Rails.application.config.slack_webhook

    ActionCable.server.broadcast "#{room}_recording_updates_channel",
      action: 'update',
      id: record_id,
      published: recording[:published],
      listed: bbb_is_recording_listed(recording)
    ActionCable.server.broadcast "#{full_id}_recording_updates_channel",
      action: 'update',
      id: record_id,
      published: recording[:published],
      listed: bbb_is_recording_listed(recording)
  end
end
