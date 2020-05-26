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

  def self.admins_order(column, direction, running_ids)
    # Include the owner of the table
    table = joins(:owner)

    # Rely on manual ordering if trying to sort by status
    return order_by_status(table, running_ids) if column == "status"

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

  # Return table with the running rooms first
  def self.order_by_status(table, ids)
    return table if ids.blank?

    order_string = "CASE bbb_id "

    ids.each_with_index do |id, index|
      order_string += "WHEN '#{id}' THEN #{index} "
    end

    order_string += "ELSE #{ids.length} END"

    table.order(Arel.sql(order_string))
  end

  private

  # Generates a uid for the room and BigBlueButton.
  def setup
    self.uid = random_room_uid
    self.bbb_id = unique_bbb_id
    self.moderator_pw = RandomPassword.generate(length: 12)
    self.attendee_pw = RandomPassword.generate(length: 12)
  end

  # Generates a fully random room uid.
  def random_room_uid
    # 6 character long random string of chars from a..z and 0..9
    full_chunk = SecureRandom.alphanumeric(6).downcase

    [owner.name_chunk, full_chunk[0..2], full_chunk[3..5]].join("-")
  end

  # Generates a unique bbb_id based on uuid.
  def unique_bbb_id
    loop do
      bbb_id = SecureRandom.alphanumeric(40).downcase
      break bbb_id unless Room.exists?(bbb_id: bbb_id)
    end
  end
end
