# frozen_string_literal: true

# Load available languages.

configured_languages = []

locales = Dir.glob("#{Rails.root}/config/locales/*")
locales.each do |loc|
  configured_languages.push(loc.split('/').last.split('.').first)
end

Rails.configuration.i18n.available_locales = configured_languages

# Enable locale fallbacks for I18n (makes lookups for any locale fall back to
# the I18n.default_locale when a translation cannot be found).
Rails.configuration.i18n.fallbacks = {}
Rails.configuration.i18n.available_locales.each do |locale|
  Rails.configuration.i18n.fallbacks[locale] = :en
end
