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

class Recording < ApplicationRecord
  VISIBILITIES = {
    published: 'Published',
    unpublished: 'Unpublished',
    protected: 'Protected',
    public: 'Public',
    public_protected: 'Public/Protected'
  }.freeze

  belongs_to :room
  has_one :user, through: :room
  has_many :formats, dependent: :destroy

  validates :name, presence: true
  validates :record_id, presence: true
  validates :visibility, presence: true
  validates :length, presence: true
  validates :participants, presence: true
  validates :visibility, inclusion: VISIBILITIES.values

  scope :with_provider, ->(current_provider) { where(user: { provider: current_provider }) }

  def self.search(input)
    if input
      return joins(:formats).where('recordings.name ILIKE :input OR recordings.visibility ILIKE :input OR formats.recording_type ILIKE :input',
                                   input: "%#{input}%").includes(:formats)
    end

    all.includes(:formats)
  end

  def self.public_search(input)
    if input
      return joins(:formats).where('recordings.name ILIKE :input OR formats.recording_type ILIKE :input',
                                   input: "%#{input}%").includes(:formats)
    end

    all.includes(:formats)
  end
end
