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

require 'bbb_api'

class Room < ApplicationRecord
  include Deleteable

  before_create :setup

  validates :name, presence: true

  belongs_to :owner, class_name: 'User', foreign_key: :user_id
  has_many :shared_access

  def self.admins_search(string)
    active_database = Rails.configuration.database_configuration[Rails.env]["adapter"]
    # Postgres requires created_at to be cast to a string
    created_at_query = if active_database == "postgresql"
      "created_at::text"
    else
      "created_at"
    end

    search_query = "rooms.name LIKE :search OR rooms.uid LIKE :search OR users.email LIKE :search" \
    " OR users.#{created_at_query} LIKE :search"

    search_param = "%#{string}%"

    where(search_query, search: search_param)
  end

  def self.admins_order(column, direction)
    # Include the owner of the table
    table = joins(:owner)

    return table.order(Arel.sql("rooms.#{column} #{direction}")) if table.column_names.include?(column)

    return table.order(Arel.sql("#{column} #{direction}")) if column == "users.name"

    table
  end

  # Determines if a user owns a room.
  def owned_by?(user)
    user_id == user&.id
  end

  def shared_users
    User.where(id: shared_access.pluck(:user_id))
  end

  def shared_with?(user)
    return false if user.nil?
    shared_users.include?(user)
  end

  # Determines the invite path for the room.
  def invite_path
    "#{Rails.configuration.relative_url_root}/#{CGI.escape(uid)}"
  end

  # Notify waiting users that a meeting has started.
  def notify_waiting
    ActionCable.server.broadcast("#{uid}_waiting_channel", action: "started")
  end

  private

  # Generates a uid for the room and BigBlueButton.
  def setup
    self.uid = random_room_uid
    self.bbb_id = unique_bbb_id
    self.moderator_pw = RandomPassword.generate(length: 12)
    self.attendee_pw = RandomPassword.generate(length: 12)
  end

  # Generates a three character uid chunk.
  def uid_chunk
    charset = ("a".."z").to_a - %w(b i l o s) + ("2".."9").to_a - %w(5 8)
    (0...3).map { charset.to_a[rand(charset.size)] }.join
  end

  # Generates a random room uid that uses the users name.
  def random_room_uid
    [owner.name_chunk, uid_chunk, uid_chunk].join('-').downcase
  end

  # Generates a unique bbb_id based on uuid.
  def unique_bbb_id
    loop do
      bbb_id = SecureRandom.hex(20)
      break bbb_id unless Room.exists?(bbb_id: bbb_id)
    end
  end
end
