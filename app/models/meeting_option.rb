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

class MeetingOption < ApplicationRecord
  has_many :room_meeting_options, dependent: :restrict_with_exception
  has_many :rooms_configurations, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true

  def self.get_setting_value(name:, room_id:)
    joins(:room_meeting_options)
      .select(:value)
      .find_by(
        name:,
        room_meeting_options: { room_id: }
      )
  end

  def self.get_config_value(name:, provider:)
    joins(:rooms_configurations)
      .where(
        name:,
        rooms_configurations: { provider: }
      )
      .pluck(:name, :value)
      .to_h
  end

  def true_value
    if name.ends_with? 'AccessCode'
      SecureRandom.alphanumeric(6).downcase
    elsif name == 'guestPolicy'
      'ASK_MODERATOR'
    else
      'true'
    end
  end
end
