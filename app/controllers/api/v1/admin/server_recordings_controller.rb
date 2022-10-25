# frozen_string_literal: true

module Api
  module V1
    module Admin
      class ServerRecordingsController < ApiController
        before_action do
          ensure_authorized('ManageRecordings')
        end

        # POST /api/v1/admin/server_recordings.json
        # Expects: {}
        # Returns: { data: Array[serializable objects] , errors: Array[String] }
        # Does: Fetches and returns the list of server recordings.

        def index
          sort_config = config_sorting(allowed_columns: %w[name length visibility])

          recordings = Recording.includes(:user)
                                .with_provider(current_provider)
                                .order(sort_config)
                                &.search(params[:search])
          pagy, recordings = pagy(recordings)

          render_data data: recordings, meta: pagy_metadata(pagy), status: :ok
        end
      end
    end
  end
end
