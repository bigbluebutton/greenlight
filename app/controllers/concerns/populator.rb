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

module Populator
  extend ActiveSupport::Concern

  # Returns a list of users that are in the same context of the current user
  def manage_users_list
    initial_list = case @tab
      when "active"
        User.without_role([:pending, :denied])
      when "deleted"
        User.deleted
      when "pending"
        User.with_role(:pending)
      when "denied"
        User.with_role(:denied)
      else
        User.all
    end

    initial_list = initial_list.with_role(@role.name) if @role.present?

    initial_list = initial_list.without_role(:super_admin)

    initial_list = initial_list.where(provider: @user_domain) if Rails.configuration.loadbalanced_configuration

    initial_list.where.not(id: current_user.id)
                .admins_search(@search)
                .admins_order(@order_column, @order_direction)
  end

  # Returns a list of rooms that are in the same context of the current user
  def server_rooms_list
    if Rails.configuration.loadbalanced_configuration
      Room.includes(:owner).where(users: { provider: @user_domain })
          .admins_search(@search)
          .admins_order(@order_column, @order_direction, @running_room_bbb_ids)
    else
      Room.includes(:owner).admins_search(@search).admins_order(@order_column, @order_direction, @running_room_bbb_ids)
    end
  end

  # Returns the correct recordings based on the users inputs
  def recordings_to_show(user = nil, room = nil)
    if user.present?
      # Find user and get his recordings
      rooms = User.find_by(email: user)&.rooms&.pluck(:bbb_id)
      return all_recordings(rooms) if user.present?

      [] # return no recs if room not found
    elsif room.present?
      # Find room and get its recordings
      room = Room.find_by(uid: room)&.bbb_id
      return all_recordings([room]) if room.present?

      []
    else
      latest_recordings
    end
  end

  # Returns a list off all current invitations
  def invited_users_list
    list = if Rails.configuration.loadbalanced_configuration
      Invitation.where(provider: @user_domain)
    else
      Invitation.all
    end

    list.admins_search(@search).order(updated_at: :desc)
  end

  private

  # Returns exactly 1 page of the latest recordings
  def latest_recordings
    return_length = Rails.configuration.pagination_number
    recordings = []
    counter = 0

    # Manually paginate through the rooms
    while recordings.length < return_length
      rooms = if Rails.configuration.loadbalanced_configuration
        Room.includes(:owner)
            .where(users: { provider: @user_domain })
            .order(last_session: :desc)
            .limit(return_length)
            .offset(counter * return_length)
            .pluck(:bbb_id)
      else
        Room.order(last_session: :desc)
            .limit(return_length)
            .offset(counter * return_length)
            .pluck(:bbb_id)
      end

      break if rooms.blank?
      counter += 1
      recordings.push(*all_recordings(rooms))
    end

    recordings[0..return_length]
  end
end
