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
    module Admin
      class ServerRecordingsController < ApiController
        before_action do
          ensure_authorized('ManageRecordings')
        end

        # POST /api/v1/admin/server_recordings.json
        # Fetches and returns the list of all server recordings
        def index
          sort_config = config_sorting(allowed_columns: %w[name length visibility])

          recordings = Recording.includes(:user)
                                .with_provider(current_provider)
                                .order(sort_config, recorded_at: :desc)
                                &.server_search(params[:search])
          pagy, recordings = pagy(recordings)

          render_data data: recordings, serializer: ServerRecordingSerializer, meta: pagy_metadata(pagy), status: :ok
        end
      end
    end
  end
end
