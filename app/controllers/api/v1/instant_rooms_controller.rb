# frozen_string_literal: true

module Api
  module V1
    class InstantRoomsController < ApiController
      skip_before_action :ensure_authenticated

      # POST /api/v1/meetings/:friendly_id/start.json
      # Returns: { data: Array[serializable objects] , errors: Array[String] }
      # Does: Starts the Room meeting and joins in the meeting starter.
      def create
        username = instant_room_params[:username]
        room = InstantRoom.new(username: username)

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



      private

      def instant_room_params
        params.require(:instant_room).permit(:username)
      end
    end
  end
end
