# frozen_string_literal: true

module Api
  module V1
    class RecordingsController < ApiController
       # TODO: - Revisit this.
      before_action :find_recording, only: :update

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

        BigBlueButtonApi.new.update_recordings record_id: @recording.record_id, meta_hash: { meta_name: new_name }
        @recording.update! name: new_name

        render_data data: @recording
      end

      def resync
        RecordingsSync.new(user: current_user).call

        render_data
      end

      def publish_recording
        publish = params[:publish]
        record_id = params[:record_id]
        case publish
        when 'true'
          visibility = 'Published'
        when 'false'
          visibility = 'Unpublished'
        end
        Recording.find_by(record_id:).update(visibility:)
        BigBlueButtonApi.new.publish_recordings(record_ids: record_id, publish:)

        render_data
      end

      private

      def recording_params
        params.require(:recording).permit(:name)
      end

      def find_recording
        @recording = Recording.find_by! record_id: params[:id]
      end
    end
  end
end
