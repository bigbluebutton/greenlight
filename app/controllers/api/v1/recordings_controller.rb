# frozen_string_literal: true

module Api
  module V1
    class RecordingsController < ApiController
      skip_before_action :verify_authenticity_token # TODO: - Revisit this.
      before_action :find_recording, only: :update
      before_action :config_sorting, only: :index, if: -> { params.key?(:sort) }

      # GET /api/v1/recordings.json
      # Returns: { data: Array[serializable objects(recordings)] , errors: Array[String] }
      # Does: Returns all the Recordings from all the current user's rooms

      def index
        recordings = current_user.recordings&.order(@sort_config)&.search(params[:search])

        # TODO: Optimise this.
        recordings.map! do |recording|
          {
            id: recording.id,
            record_id: recording.record_id,
            name: recording.name,
            length: recording.length,
            users: recording.users,
            visibility: recording.visibility,
            created_at: recording.created_at.strftime('%A %B %e, %Y %l:%M%P'),
            formats: recording.formats
          }
        end

        render_json data: recordings, status: :ok
      end

      def destroy
        # TODO: - Need to change this to work preferably with after_destroy in recordings model
        BigBlueButtonApi.new.delete_recordings(record_ids: params[:id])

        Recording.destroy_by(record_id: params[:id])

        render_json(status: :ok)
      end

      # PUT/PATCH /api/v1/recordings/:recording_id.json
      # Returns: { data: Array[serializable objects(recordings)] , errors: Array[String] }
      # Does: Update the recording name.
      def update
        new_name = recording_params[:name]
        return render_json errors: [Rails.configuration.custom_error_msgs[:missing_params]], status: :bad_request if new_name.blank?

        BigBlueButtonApi.new.update_recordings record_id: @recording.record_id, meta_hash: { meta_name: new_name }
        Recording.update! @recording.id, name: new_name

        render_json
      end

      def resync
        RecordingsSync.new(user: current_user).call

        render_json(status: :ok)
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

        render_json(status: :ok)
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
