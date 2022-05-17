# frozen_string_literal: true

module Api
  module V1
    class SharedAccessesController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :find_room

      # POST /api/v1/shared_accesses/room/friendly_id.json
      def create
        users = User.where(id: params[:users][:shared_users])

        users.each do |user|
          SharedAccess.find_or_create_by!(user_id: user.id, room_id: @room.id) if user.room_shareable?(@room)
        end

        render_json status: :ok
      end

      # DELETE /api/v1/shared_accesses/room/friendly_id.json
      def destroy
        user = User.find_by(id: params[:user_id])

        SharedAccess.find_by!(user_id: user.id, room_id: @room.id).delete

        render_json status: :ok
      end

      # GET /api/v1/shared_accesses/room/friendly_id/shared_users.json
      def shared_users
        shared_users = []

        # User is added to the shared_user list if the room is shared to the user and it is not already included in shared_user
        User.all.each do |user|
          shared_users << user if user.room_shared?(@room) && shared_users.exclude?(user)
        end

        shared_users.map! do |user|
          {
            id: user.id,
            name: user.name,
            email: user.email,
            avatar: user.user_avatar
          }
        end

        render_json data: shared_users, status: :ok
      end

      # GET /api/v1/shared_accesses/room/friendly_id/shareable_users.json
      def shareable_users
        shareable_users = []

        # User is added to the shareable_user list unless it's the room owner or the room is already shared to the user
        User.all.each do |user|
          shareable_users << user if user.room_shareable?(@room)
        end

        shareable_users.map! do |user|
          {
            id: user.id,
            name: user.name,
            email: user.email,
            avatar: user.user_avatar
          }
        end

        render_json data: shareable_users, status: :ok
      end

      private

      def find_room
        @room = Room.find_by(friendly_id: params[:friendly_id])
      end
    end
  end
end
