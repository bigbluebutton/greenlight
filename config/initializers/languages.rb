# frozen_string_literal: true

# Load available languages.

configured_languages = []

locales = Dir.glob("#{Rails.root}/config/locales/*")
locales.each do |loc|
  configured_languages.push(loc.split('/').last.split('.').first)
end

Rails.configuration.i18n.available_locales = configured_languages

# Configure default locale
Rails.configuration.i18n.default_locale =
  if Rails.configuration.i18n.available_locales.include?(ENV["DEFAULT_LOCALE"])
    ENV["DEFAULT_LOCALE"].to_sym
  else
    :en
  end

# Configure fallbacks
Rails.configuration.i18n.available_locales.each do |locale|
  Rails.configuration.i18n.fallbacks[locale] = [locale, :en]
end
