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

json.partial! 'bbb', messageKey: @messageKey, message: @message, status: @status
json.is_owner current_user == @user
json.recordings do
  json.array!(@response) do |recording|
    json.id recording[:recordID]
    json.name recording[:name]
    json.start_time recording[:startTime]
    json.end_time recording[:endTime]
    json.published recording[:published]
    json.length recording[:length]
    json.listed recording[:listed]
    if recording[:participants].is_a? String
      json.participants recording[:participants]
    else
      json.participants nil
    end
    json.previews do
      json.array!(recording[:previews]) do |preview|
        json.partial! 'preview', preview: preview
      end
    end
    json.playbacks do
      json.array!(recording[:playbacks]) do |playback|
        json.type playback[:type]
        json.type_i18n t(playback[:type]) # translates the playback type
        json.url playback[:url]
        json.previews do
          json.array!(playback[:previews]) do |preview|
            json.partial! 'preview', preview: preview
          end
        end
      end
    end
  end
end
