# frozen_string_literal: true

module Api
  module V1
    class RecordingsController < ApplicationController
      skip_before_action :verify_authenticity_token # TODO: - Revisit this.

      # GET /api/v1/recordings.json
      # Returns: { data: Array[serializable objects(recordings)] , errors: Array[String] }
      # Does: Returns all the Recordings from all the current user's rooms
      def index
        recordings = current_user.recordings&.includes(:formats)

        render_json(data: recordings, status: :ok, include: :formats)
      end

      def recordings
        recording_sync = RecordingsSync.new
        recording_sync.recordings_resync(user: current_user)

        render_json(status: :ok)
      end
    end
  end
end
