# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
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

module RecordingsHelper
  # Helper for converting BigBlueButton dates into the desired format.
  def recording_date(date)
    I18n.l date, format: "%B %d, %Y"
  end

  # Helper for converting BigBlueButton dates into a nice length string.
  def recording_length(playbacks)
    # Looping through playbacks array and returning first non-zero length value
    playbacks.each do |playback|
      length = playback[:length]
      return recording_length_string(length) unless length.zero?
    end
    # Return '< 1 min' if length values are zero
    "< 1 min"
  end

  # Prevents single images from erroring when not passed as an array.
  def safe_recording_images(images)
    Array.wrap(images)
  end

  def room_uid_from_bbb(bbb_id)
    Room.find_by(bbb_id: bbb_id)[:uid]
  end

  # returns whether recording thumbnails are enabled on the server
  def recording_thumbnails?
    Rails.configuration.recording_thumbnails
  end

  private

  # Returns length of the recording as a string
  def recording_length_string(len)
    if len > 60
      "#{(len / 60).to_i} h #{len % 60} min"
    else
      "#{len} min"
    end
  end
end
