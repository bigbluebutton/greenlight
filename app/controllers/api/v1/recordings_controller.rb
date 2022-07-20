# frozen_string_literal: true

module Api
  module V1
    class RecordingsController < ApiController
      before_action :find_recording, only: %i[update update_visibility]

      # GET /api/v1/recordings.json
      # Returns: { data: Array[serializable objects(recordings)] , errors: Array[String] }
      # Does: Returns all the Recordings from all the current user's rooms

      def index
        sort_config = config_sorting(allowed_columns: %w[name length visibility])

        recordings = current_user.recordings&.order(sort_config)&.search(params[:search])

        render_data data: recordings, status: :ok
      end

      def destroy
        # TODO: - Need to change this to work preferably with after_destroy in recordings model
        BigBlueButtonApi.new.delete_recordings(record_ids: params[:id])

        Recording.destroy_by(record_id: params[:id])

        render_data status: :ok
      end

      # PUT/PATCH /api/v1/recordings/:recording_id.json
      # Returns: { data: Array[serializable objects(recordings)] , errors: Array[String] }
      # Does: Update the recording name.
      def update
        new_name = recording_params[:name]
        return render_error errors: [Rails.configuration.custom_error_msgs[:missing_params]] if new_name.blank?

        BigBlueButtonApi.new.update_recordings record_id: @recording.record_id, meta_hash: { meta_name: new_name }
        @recording.update! name: new_name

        render_data data: @recording, status: :ok
      end

      def resync
        RecordingsSync.new(user: current_user).call

        render_data status: :ok
      end

      # POST /api/v1/recordings/update_visibility.json
      # unpublished -> protected (publish: true, protected: true)
      # unpublished -> published (publish: true, protected: false)
      # protected -> unpublished (publish: false, protected: false)
      # protected -> published (publish: true, protected: false)
      # published -> protected (publish: true, protected: true)
      # published -> unpublished (publish: false, protected: false)
      def update_visibility
        new_visibility = params[:visibility]
        old_visibility = @recording.visibility
        bbb_api = BigBlueButtonApi.new

        bbb_api.publish_recordings(record_ids: @recording.record_id, publish: true) if old_visibility == 'Unpublished'

        bbb_api.publish_recordings(record_ids: @recording.record_id, publish: false) if new_visibility == 'Unpublished'

        bbb_api.update_recordings(record_id: @recording.record_id, meta_hash: { protect: true }) if new_visibility == 'Protected'

        bbb_api.update_recordings(record_id: @recording.record_id, meta_hash: { protect: false }) if old_visibility == 'Protected'

        @recording.update!(visibility: new_visibility)

        render_data status: :ok
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
