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

module APIConcern
  extend ActiveSupport::Concern

  # Format recordings to match their current use in the app
  def format_recordings(api_res)
    api_res[:recordings].each do |r|
      next if r.key?(:error)
      # Format playbacks in a more pleasant way.
      r[:playbacks] = if !r[:playback] || !r[:playback][:format]
        []
      elsif r[:playback][:format].is_a?(Array)
        r[:playback][:format]
      else
        [r[:playback][:format]]
      end
      r.delete(:playback)
    end

    api_res[:recordings].sort_by { |rec| rec[:endTime] }.reverse
  end
end
