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

module Presentable
  extend ActiveSupport::Concern

  def presentation_file_name(room)
    room.presentation.filename if room.presentation.attached?
  end

  def presentation_thumbnail(room)
    return if !room.presentation.attached? || !room.presentation.representable?

    view_context.rails_representation_url(room.presentation.representation(resize: ['225x125']).processed)
  end

  def presentation_url(room)
    return unless room.presentation.attached?

    view_context.url_for(room.presentation)
  end

  def presentation_content_type(room)
    return unless room.presentation.attached?

    room.presentation.blob.content_type
  end

  def presentation_byte_size(room)
    return unless room.presentation.attached?

    room.presentation.blob.byte_size
  end

  def presentation_created_at(room)
    return unless room.presentation.attached?

    room.presentation.attachment&.created_at
  end

  def room_thumbnail_image(room)
    return unless room.thumbnail_image.attached?

    view_context.url_for(room.thumbnail_image)
  end
end
