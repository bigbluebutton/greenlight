# frozen_string_literal: true

require "rails"
require "active_storage"

require "active_storage/previewer/poppler_pdf_previewer"
require "active_storage/previewer/mupdf_previewer"
require "active_storage/previewer/video_previewer"

require "active_storage/analyzer/image_analyzer"
require "active_storage/analyzer/video_analyzer"

require "active_storage/reflection"

module ActiveStorage
  class Engine < Rails::Engine # :nodoc:
    isolate_namespace ActiveStorage

    config.active_storage = ActiveSupport::OrderedOptions.new
    config.active_storage.previewers = [ ActiveStorage::Previewer::PopplerPDFPreviewer, ActiveStorage::Previewer::MuPDFPreviewer, ActiveStorage::Previewer::VideoPreviewer ]
    config.active_storage.analyzers = [ ActiveStorage::Analyzer::ImageAnalyzer, ActiveStorage::Analyzer::VideoAnalyzer ]
    config.active_storage.paths = ActiveSupport::OrderedOptions.new

    config.active_storage.variable_content_types = %w(
      image/png
      image/gif
      image/jpg
      image/jpeg
      image/vnd.adobe.photoshop
      image/vnd.microsoft.icon
    )

    config.active_storage.content_types_to_serve_as_binary = %w(
      text/html
      text/javascript
      image/svg+xml
      application/postscript
      application/x-shockwave-flash
      text/xml
      application/xml
      application/xhtml+xml
    )

    config.eager_load_namespaces << ActiveStorage

    initializer "active_storage.configs" do
      config.after_initialize do |app|
        ActiveStorage.logger            = app.config.active_storage.logger || Rails.logger
        ActiveStorage.queue             = app.config.active_storage.queue
        ActiveStorage.variant_processor = app.config.active_storage.variant_processor || :mini_magick
        ActiveStorage.previewers        = app.config.active_storage.previewers || []
        ActiveStorage.analyzers         = app.config.active_storage.analyzers || []
        ActiveStorage.paths             = app.config.active_storage.paths || {}
        ActiveStorage.routes_prefix     = app.config.active_storage.routes_prefix || "/rails/active_storage"

        ActiveStorage.variable_content_types = app.config.active_storage.variable_content_types || []
        ActiveStorage.content_types_to_serve_as_binary = app.config.active_storage.content_types_to_serve_as_binary || []
        ActiveStorage.service_urls_expire_in = app.config.active_storage.service_urls_expire_in || 5.minutes
      end
    end

    initializer "active_storage.attached" do
      require "active_storage/attached"

      ActiveSupport.on_load(:active_record) do
        include ActiveStorage::Attached::Model
      end
    end

    initializer "active_storage.verifier" do
      config.after_initialize do |app|
        ActiveStorage.verifier = app.message_verifier("ActiveStorage")
      end
    end

    initializer "active_storage.services" do
      ActiveSupport.on_load(:active_storage_blob) do
        if config_choice = Rails.configuration.active_storage.service
          configs = Rails.configuration.active_storage.service_configurations ||= begin
                                                                                    config_file = Pathname.new(Rails.root.join("config/storage.yml"))
                                                                                    raise("Couldn't find Active Storage configuration in #{config_file}") unless config_file.exist?

                                                                                    require "yaml"
                                                                                    require "erb"

                                                                                    YAML.load(ERB.new(config_file.read).result) || {}
                                                                                  rescue Psych::SyntaxError => e
                                                                                    raise "YAML syntax error occurred while parsing #{config_file}. " \
                  "Please note that YAML must be consistently indented using spaces. Tabs are not allowed. " \
                  "Error: #{e.message}"
                                                                                  end

          ActiveStorage::Blob.service =
            begin
              ActiveStorage::Service.configure config_choice, configs
            rescue => e
              raise e, "Cannot load `Rails.config.active_storage.service`:\n#{e.message}", e.backtrace
            end
        end
      end
    end

    initializer "active_storage.reflection" do
      ActiveSupport.on_load(:active_record) do
        include Reflection::ActiveRecordExtensions
        ActiveRecord::Reflection.singleton_class.prepend(Reflection::ReflectionExtension)
      end
    end
  end
end
