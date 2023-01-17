# frozen_string_literal: true

module Api
  module V1
    class SharedAccessesController < ApiController
      before_action :find_room

      before_action only: %i[show create destroy shareable_users] do
        ensure_authorized('ManageRooms', friendly_id: params[:friendly_id])
      end

      # POST /api/v1/shared_accesses.json
      # Shares the room with all of the specified users
      def create
        shared_users_ids = Array(params[:shared_users])

        shared_users_ids.each do |shared_user_id|
          SharedAccess.create(user_id: shared_user_id, room_id: @room.id)
        end

        render_data status: :ok
      end

      # DELETE /api/v1/shared_accesses/friendly_id.json
      # Unshares a room with the specified user
      def destroy
        SharedAccess.delete_by(user_id: params[:user_id], room_id: @room.id)

        render_data status: :ok
      end

      # GET /api/v1/shared_accesses/:friendly_id.json
      # Returns a list of all of the room's shared users
      def show
        render_data data: @room.shared_users.search(params[:search]), serializer: SharedAccessSerializer, status: :ok
      end

      # GET /api/v1/shared_accesses/friendly_id/shareable_users.json
      # Returns a list of users with whom a room can be shared with (based on role permissions)
      def shareable_users
        return render_error status: :bad_request unless params[:search].present? && params[:search].length >= 3

        # role_id of roles that have SharedList permission set to true
        role_ids = RolePermission.joins(:permission).where(permission: { name: 'SharedList' }).where(value: 'true').pluck(:role_id)

        # Can't share the room if it's already shared or it's the room owner
        shareable_users = User.with_attached_avatar
                              .where.not(id: [@room.shared_users.pluck(:id) << @room.user_id])
                              .where(role_id: [role_ids])
                              .search(params[:search])
        render_data data: shareable_users, serializer: SharedAccessSerializer, status: :ok
      end

      private

      def find_room
        @room = Room.find_by(friendly_id: params[:friendly_id])
      end
    end
  end
end
