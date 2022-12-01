# frozen_string_literal: true

module Api
  module V1
    class InstantRoomsController < ApiController
      before_action :find_instant_room, only: %i[show join]
      skip_before_action :ensure_authenticated

      # POST /api/v1/meetings/:friendly_id/start.json
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Starts the Room meeting and joins in the meeting starter.
      def create
        username = instant_room_params[:username]
        room = InstantRoom.new(username:)

        if room.save
          logger.info "instant_room(friendly_id):#{room.friendly_id} created"

          begin
            InstantMeetingStarter.new(room:, base_url: root_url).call
          rescue BigBlueButton::BigBlueButtonException => e
            return render_error status: :bad_request unless e.key == 'idNotUnique'
          end

          render_data data: BigBlueButtonApi.new.join_meeting(
            room:,
            name: username,
            role: 'Moderator'
          ), status: :created

        else
          render_error errors: room.errors.to_a, status: :bad_request
        end
      end

      def destroy
        if @room.destroy
          render_data status: :ok
        else
          render_error errors: @room.errors.to_a, status: :bad_request
        end
      end

      def show
        render_data data: @room, status: :ok
      end

      # feel like only this method would justify creating a instant_meetings_controller?
      def join
        join_url = BigBlueButtonApi.new.join_meeting(
          room: @room,
          name: params[:name],
          role: 'Viewer'
        )
        render_data data: join_url, status: :created
      end

      private

      def find_instant_room
        @room = InstantRoom.find_by!(friendly_id: params[:friendly_id])
      end

      def instant_room_params
        params.require(:instant_room).permit(:username)
      end
    end
  end
end
