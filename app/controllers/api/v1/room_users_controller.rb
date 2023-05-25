module Api
  module V1
    class RoomUsersController < ApiController
      skip_before_action :ensure_authenticated, only: %i[public_show]
      before_action :find_room, only: %i[show update destroy recordings recordings_processing purge_presentation public_show]

      # GET /api/v1/room_users.json
      # Return a list of the current_user's room for event
      def index
        room_users = RoomUser.where(user_id: current_user.id)

        render_data data: room_users, status: :ok
      end

      # GET /api/v1/:friendly_id/:event_id.json
      # Return or check if exists room current_user event association
      def show
        RunningMeetingChecker.new(rooms: @room, provider: current_provider).call if @room.online

        @room.shared = current_user.shared_rooms.include?(@room)

        registration = RoomUser.where(user_id: current_user.id)
          .and(room_id: @room.id)
          .and(event_id: params[:event_id])

        render_error status: :not_found unless registration

        render_data data: @room, serializer: CurrentRoomSerializer, status: :ok
      end

      # POST /api/v1/room_users.json
      # Create association between current_user, room, and some event
      def create 
        room = nil
        if params[:friendly_id]
          room = Room.find_by!(friendly_id: params[:friendly_id])
        else
          room = Room.find_by!(id: room_user_event_params[:room_id])
        end

        user_id = room_user_event_params[:user_id]

        if !user_id
          user_id = current_user.id
        end

        registration = RoomUser.new(room_id: room.id, user_id: user_id, event_id: room_user_event_params[:event_id])

        if registration.save
          logger.info "association: room(friendly_id):#{room.friendly_id} created for user(id):#{room.user_id} on event(id):#{room_user_event_params[:event_id]}"
          data = { "room" => { "friendly_id" => room.friendly_id, "name": room.name, "user" => { "name" => current_user.name }, "external_event_id": registration.event_id } }
          render_data data: data, status: :created
        else
          render_error errors: room.errors.to_a, status: :bad_request
        end
      end

      # DELETE /api/v1/room_users/:friendly_id.json
      # Delete data from database
      def destroy
        where_str = "";
        
        if @room
          where_str = "room_id = :room_id"
        end
        if params[:user_id]
          where_str = where_str + " and user_id = :user_id"
        end
        if params[:event_id]
          where_str = where_str + " and event_id = :event_id"
        end

        results = RoomUser.where([where_str, { room_id: @room.id, user_id: params[:user_id], event_id: params[:event_id] }]).delete_all

        # if data.length <= 0
        #   return render_error status: :not_found
        # end

        # data.each { |d| d.delete("room_id = '#{d.room_id}' and user_id = '#{d.user_id}' and event_id = '#{d.event_id}'") }

        render_data data: results, status: :ok
      end

      private 

      def find_room
        @room = Room.find_by!(friendly_id: params[:friendly_id])
      end

      def room_user_event_params
        params.require(:room_user).permit(:friendly_id, :user_id, :event_id)
      end
    end
  end
end