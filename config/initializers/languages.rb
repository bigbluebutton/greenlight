# frozen_string_literal: true

# Load available languages.

configured_languages = []

locales = Dir.glob("#{Rails.root}/config/locales/*")
locales.each do |loc|
  configured_languages.push(loc.split('/').last.split('.').first)
end

Rails.configuration.i18n.available_locales = configured_languages
