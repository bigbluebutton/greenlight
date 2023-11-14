# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

# frozen_string_literal: true

module Api
  module V1
    class RecordingsController < ApiController
      skip_before_action :ensure_authenticated, only: :recording_url

      before_action :find_recording, only: %i[update update_visibility recording_url]
      before_action only: %i[destroy] do
        ensure_authorized('ManageRecordings', record_id: params[:id])
      end
      before_action only: %i[update update_visibility recording_url] do
        ensure_authorized(%w[ManageRecordings SharedRoom PublicRecordings], record_id: params[:id])
      end
      before_action only: %i[index recordings_count] do
        ensure_authorized('CreateRoom')
      end

      # GET /api/v1/recordings.json
      # Returns all of the current_user's recordings
      def index
        sort_config = config_sorting(allowed_columns: %w[name length visibility])

        pagy, recordings = pagy(current_user.recordings&.order(sort_config, recorded_at: :desc)&.search(params[:search]), items: 5)
        render_data data: recordings, meta: pagy_metadata(pagy), status: :ok
      end

      # PUT/PATCH /api/v1/recordings/:id.json
      # Updates a recording's name in both BigBlueButton and Greenlight
      def update
        new_name = recording_params[:name]
        return render_error errors: [Rails.configuration.custom_error_msgs[:missing_params]] if new_name.blank?

        BigBlueButtonApi.new(provider: current_provider).update_recordings record_id: @recording.record_id, meta_hash: { meta_name: new_name }
        @recording.update! name: new_name

        render_data data: @recording, status: :ok
      end

      # DELETE /api/v1/recordings/:id.json
      # Deletes a recording in both BigBlueButton and Greenlight
      def destroy
        Recording.destroy_by(record_id: params[:id])

        render_data status: :ok
      end

      # POST /api/v1/recordings/update_visibility.json
      # Update's a recordings visibility by setting publish/unpublish and protected/unprotected
      def update_visibility
        new_visibility = params[:visibility].to_s

        new_visibility_params = visibility_params_of(new_visibility)

        return render_error status: :bad_request if new_visibility_params.nil?

        bbb_api = BigBlueButtonApi.new(provider: current_provider)

        bbb_api.publish_recordings(record_ids: @recording.record_id, publish: new_visibility_params[:publish])
        bbb_api.update_recordings(record_id: @recording.record_id, meta_hash: new_visibility_params[:meta_hash])

        @recording.update!(visibility: new_visibility)

        render_data status: :ok
      end

      # GET /api/v1/recordings/recordings_count.json
      # Returns the total number of recordings for the current_user
      def recordings_count
        count = current_user.recordings.count
        render_data data: count, status: :ok
      end

      # POST /api/v1/recordings/recording_url.json
      def recording_url
        record_format = params[:recording_format]

        urls = if [Recording::VISIBILITIES[:protected], Recording::VISIBILITIES[:public_protected]].include? @recording.visibility
                 recording = BigBlueButtonApi.new(provider: current_provider).get_recording(record_id: @recording.record_id)
                 formats = recording[:playback][:format]
                 formats = [formats] unless formats.is_a? Array

                 if record_format.present?
                   found_format = formats.find { |format| format[:type] == record_format }
                   return render_error status: :not_found unless found_format

                   found_format[:url]
                 else
                   formats.pluck(:url)
                 end
               elsif record_format.present?
                 found_format = @recording.formats.find_by(recording_type: record_format)
                 return render_error status: :not_found unless found_format

                 found_format[:url]
               else
                 @recording.formats.pluck(:url)
               end

        render_data data: urls, status: :ok
      end

      private

      def recording_params
        params.require(:recording).permit(:name)
      end

      def find_recording
        @recording = Recording.find_by! record_id: params[:id]
      end

      def visibility_params_of(visibility)
        params_of = {
          Recording::VISIBILITIES[:unpublished] => { publish: false, meta_hash: { protect: false, 'meta_gl-listed': false } },
          Recording::VISIBILITIES[:published] => { publish: true, meta_hash: { protect: false, 'meta_gl-listed': false } },
          Recording::VISIBILITIES[:public] => { publish: true, meta_hash: { protect: false, 'meta_gl-listed': true } },
          Recording::VISIBILITIES[:protected] => { publish: true, meta_hash: { protect: true, 'meta_gl-listed': false } },
          Recording::VISIBILITIES[:public_protected] => { publish: true, meta_hash: { protect: true, 'meta_gl-listed': true } }
        }

        params_of[visibility.to_s]
      end
    end
  end
end
