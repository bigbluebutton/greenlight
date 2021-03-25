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

class NeelzMailer < ApplicationMailer
  include ApplicationHelper
  include ThemingHelper

  default from: Rails.configuration.smtp_sender

  def participation_invite_email(proband_email,url,code,interviewer_name,proband_name,study_name)
    @url = url
    @code = code
    @proband_email = proband_email
    @interviewer_name = interviewer_name
    @proband_name = proband_name
    @study_name = study_name
    @image = logo_image_email
    @from = "#{interviewer_name} ~ via #{Rails.configuration.smtp_sender}"
    @reply_to = "#{interviewer_name} <#{Rails.configuration.neelz_email}>"
    mail to: @proband_email, subject: "Einladung zum Interview", from: @from
  end

end
