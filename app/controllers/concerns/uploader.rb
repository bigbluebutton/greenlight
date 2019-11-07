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

require 'open-uri'

module Uploader
  extend ActiveSupport::Concern

  # Converts the users image link to an avatar file stored
  def convert_image_to_avatar(user)
    begin
      # Get the last part of the url
      name = user.image.split("/").last

      file = File.open(user.image)

      # Upload file if its an image
      user.avatar.attach(io: file, filename: name) if file.content_type.start_with?("image/")
    rescue e
      logger.error("Support: Image URL is not valid/available - #{user.uid} - #{user.image}")
    end
  end

  def invalid_image_upload(avatar)
    avatar.present? && !avatar.content_type.start_with?("image/")
  end
end
