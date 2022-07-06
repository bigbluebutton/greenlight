# frozen_string_literal: true

module Api
  module V1
    class SharedAccessesController < ApiController
      
      before_action :find_room

      include Avatarable

      # POST /api/v1/shared_accesses.json
      def create
        user_ids = params[:shared_users]

        shared_accesses = user_ids.map { |user_id| { user_id:, room_id: @room.id } }

        SharedAccess.create(shared_accesses)

        render_data
      end

      # DELETE /api/v1/shared_accesses/friendly_id.json
      def destroy
        SharedAccess.delete_by(user_id: params[:user_id], room_id: @room.id)

        render_data
      end

      # GET /api/v1/shared_accesses/friendly_id.json
      def show
        render_data data: @room.shared_users.search(params[:search])
      end

      # GET /api/v1/shared_accesses/friendly_id/shareable_users.json
      def shareable_users
        # Can't share the room if it's already shared or it's the room owner
        render_data data: User.with_attached_avatar
                              .where.not(id: [@room.shared_users.pluck(:id) << @room.user_id])
                              .search(params[:search])
      end

      private

      def find_room
        @room = Room.find_by(friendly_id: params[:friendly_id])
      end
    end
  end
end
