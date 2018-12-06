# frozen_string_literal: true

# Load available languages.

locales = "#{Rails.root}/config/locales/*"

configured_languages = []

Dir.glob(locales) do |loc|
  configured_languages.push(loc.split('/').last.split('.').first)
end

Rails.configuration.languages = configured_languages
