# frozen_string_literal: true

module Api
  module V1
    class RecordingsController < ApiController
      before_action :find_recording, only: %i[update update_visibility]
      before_action :config_sorting, only: :index, if: -> { params.key?(:sort) }

      # GET /api/v1/recordings.json
      # Returns: { data: Array[serializable objects(recordings)] , errors: Array[String] }
      # Does: Returns all the Recordings from all the current user's rooms

      def index
        sort_config = config_sorting(allowed_columns: %w[name length visibility])

        recordings = current_user.recordings&.order(sort_config)&.search(params[:search])

        render_data data: recordings
      end

      def destroy
        # TODO: - Need to change this to work preferably with after_destroy in recordings model
        BigBlueButtonApi.new.delete_recordings(record_ids: params[:id])

        Recording.destroy_by(record_id: params[:id])

        render_data
      end

      # PUT/PATCH /api/v1/recordings/:recording_id.json
      # Returns: { data: Array[serializable objects(recordings)] , errors: Array[String] }
      # Does: Update the recording name.
      def update
        new_name = recording_params[:name]
        return render_error errors: [Rails.configuration.custom_error_msgs[:missing_params]] if new_name.blank?

        BigBlueButtonApi.new.update_recordings record_ids: @recording.record_id, meta_hash: { meta_name: new_name }
        @recording.update! name: new_name

        render_data data: @recording
      end

      def resync
        RecordingsSync.new(user: current_user).call

        render_data
      end

      # POST /api/v1/recordings/update_visibility.json
      def update_visibility
        visibility = params[:visibility]
        bbb_server = BigBlueButtonApi.new

        # Sends a publish request only if the bbb recording published param needs to be toggled
        if send_publish_request?(@recording, visibility)
          bbb_server.publish_recordings(record_ids: @recording.record_id, publish: %w[Protected Published].include?(visibility))
        end

        # Sends an update request only if the bbb recording protected param needs to be toggled
        if send_update_request?(@recording, visibility)
          bbb_server.update_recordings(record_ids: @recording.record_id, meta_hash: { meta_protected: visibility == 'Protected' })
        end

        @recording.update!(visibility:)

        render_data
      end

      private

      def recording_params
        params.require(:recording).permit(:name)
      end

      def config_sorting
        allowed_columns = %w[name length visibility]
        allowed_directions = %w[ASC DESC]
        sort_column = params[:sort][:column]
        sort_direction = params[:sort][:direction]

        return render_json status: :bad_request unless allowed_columns.include?(sort_column) && allowed_directions.include?(sort_direction)

        @sort_config = { sort_column => sort_direction }
      end

      def find_recording
        @recording = Recording.find_by! record_id: params[:id]
      end
    end
  end
end
