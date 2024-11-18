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
    class LocalesController < ApiController
      skip_before_action :ensure_authenticated, only: :show
      skip_before_action :ensure_valid_request, only: :show

      # GET /api/v1/locales
      # Returns a cached list of locales available
      def index
        language_with_name = Rails.cache.fetch('v3/locales/list', expires_in: 24.hours) do
          language_hash = {}

          languages = Dir.entries(Rails.root.join('app/assets/locales')).select { |file_name| file_name.ends_with?('.json') }
          language_list = I18n::Language::Mapping.language_mapping_list

          languages.each do |lang|
            language = lang.split('.').first.tr('_', '-')
            native_name = language_list.dig(language, 'nativeName')

            language_hash[language] = native_name if native_name.present?
          end

          language_hash
        end

        render_data data: language_with_name, status: :ok
      end

      # GET /api/v1/locales/:name
      # Returns the requested language's locale strings (returns 406 if locale doesn't exist)
      def show
        language = params[:name].tr('-', '_')
        language_file = Dir.entries('app/assets/locales').select { |f| f.starts_with?(language) }
        final_language = language_file.min&.gsub('.json', '')

        # Serve locales files directly in development (not through asset pipeline)
        return render file: Rails.root.join('app', 'assets', 'locales', "#{final_language}.json") if Rails.env.development?

        redirect_to ActionController::Base.helpers.asset_path("#{final_language}.json")
      rescue StandardError
        head :not_acceptable
      end
    end
  end
end
