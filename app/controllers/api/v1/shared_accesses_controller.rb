# frozen_string_literal: true

module Api
  module V1
    class SharedAccessesController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :find_room

      # POST /api/v1/shared_accesses/room/friendly_id.json
      def create
        users = User.where(id: params[:users][:shared_users])

        SharedAccess.create(users.map { |user| { user_id: user.id, room_id: @room.id } })

        render_json status: :ok
      end

      # DELETE /api/v1/shared_accesses/room/friendly_id.json
      def destroy
        user = User.find_by(id: params[:user_id])

        SharedAccess.delete_by(user_id: user.id, room_id: @room.id)

        render_json status: :ok
      end

      # GET /api/v1/shared_accesses/room/friendly_id.json
      def show
        shared_users = []

        @room.shared_users.each do |user|
          shared_users << user
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

        User.where.not(id: [@room.shared_users.pluck(:id) << @room.user_id]).each do |user|
          shareable_users << user
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
