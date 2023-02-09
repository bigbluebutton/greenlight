# frozen_string_literal: true

module Api
  module V1
    class LocalesController < ApiController
      skip_before_action :ensure_authenticated, only: :show
      skip_before_action :ensure_valid_request, only: :show

      # GET /api/v1/locales
      # Returns a cached list of locales available
      def index
        language_with_name = Rails.cache.fetch('locales/list', expires_in: 24.hours) do
          language_hash = {}

          languages = Rails.root.join('app/assets/locales').entries.select { |file_name| file_name.ends_with?('.json') }
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

        # Serve locales files directly in development (not through asset pipeline)
        return render file: Rails.root.join('app', 'assets', 'locales', "#{language}.json") if Rails.env.development?

        redirect_to ActionController::Base.helpers.asset_path("#{language}.json")
      rescue StandardError
        head :not_acceptable
      end
    end
  end
end
