# frozen_string_literal: true

module Api
  module V1
    class SharedAccessesController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :find_room

      include Avatarable

      # POST /api/v1/shared_accesses.json
      def create
        user_ids = params[:users][:shared_users]

        shared_accesses = user_ids.map { |user_id| { user_id:, room_id: @room.id } }

        SharedAccess.create(shared_accesses)

        render_json status: :ok
      end

      # DELETE /api/v1/shared_accesses/friendly_id.json
      def destroy
        SharedAccess.delete_by(user_id: params[:user_id], room_id: @room.id)

        render_json status: :ok
      end

      # GET /api/v1/shared_accesses/friendly_id.json
      def show
        shared_users = @room.shared_users.to_a

        shared_users.map! do |user|
          {
            id: user.id,
            name: user.name,
            email: user.email,
            avatar: user_avatar(user)
          }
        end

        render_json data: shared_users, status: :ok
      end

      # GET /api/v1/shared_accesses/friendly_id/shareable_users.json
      def shareable_users
        # Can't share the room if it's already shared or it's the room owner
        unshareable_users = [@room.shared_users.pluck(:id) << @room.user_id]
        shareable_users = User.where.not(id: unshareable_users).to_a

        shareable_users.map! do |user|
          {
            id: user.id,
            name: user.name,
            email: user.email,
            avatar: user_avatar(user)
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
