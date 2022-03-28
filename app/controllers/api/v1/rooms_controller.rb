# frozen_string_literal: true

module Api
  module V1
    class RoomsController < ApplicationController
      before_action :find_room, only: :show

      def show
        if @room
          render json: {
            data: @room,
            errors: []
          }, status: :ok
        else
          render json: {
            data: [],
            errors: []
          }, status: :not_found
        end
      end

      private

      def find_room
        @room = Room.find_by(friendly_id: params[:friendly_id])
      end
    end
  end
end
