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

class RoomSerializer < ApplicationSerializer
  include Presentable

  attributes :id,
             :name,
             :friendly_id,
             :meeting_id,
             :icon_key,
             :room_thumbnail_url,
             :online,
             :participants,
             :last_session,
             :presentation_name,
             :presentation_url,
             :presentation_content_type,
             :presentation_byte_size,
             :presentation_created_at

  attribute :shared_owner, if: -> { object.shared }

  def shared_owner
    object.user.name
  end

  def icon_key
    object.icon_key
  end

  def room_thumbnail_url
    room_thumbnail_image(object)
  end

  def presentation_name
    presentation_file_name(object)
  end

  def presentation_url
    return unless object.presentation.attached?

    view_context.url_for(object.presentation)
  end

  def presentation_content_type
    return unless object.presentation.attached?

    object.presentation.blob.content_type
  end

  def presentation_byte_size
    return unless object.presentation.attached?

    object.presentation.blob.byte_size
  end

  def presentation_created_at
    return unless object.presentation.attached?

    object.presentation.attachment&.created_at
  end
end
