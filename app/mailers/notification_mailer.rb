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

class NotificationMailer < ActionMailer::Base
  default from: Rails.configuration.smtp_from

  def recording_ready_email(user, rec)
    @user = user
    @recording = rec
    @duration = JSON.parse(rec[:duration])
    @room_url = meeting_room_url(resource: 'rooms', id: user.encrypted_id)

    # Need this because URL doesn't respect the relative_url_root by default
    unless @room_url.include? "#{Rails.configuration.relative_url_root}/"
      @room_url = @room_url.split('/rooms/').join("#{Rails.configuration.relative_url_root}/rooms/")
    end

    mail(to: user.email, subject: t('.subject', recording: @recording[:name]))
  end
end
