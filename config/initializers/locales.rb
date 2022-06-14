# frozen_string_literal: true

# Default language initialization.
# The default language will be used to define the default language config for all users
# that GL coudn't infer their preferred language from their browsers.
I18n.default_locale = ENV.fetch('DEFAULT_LOCALE', 'en')
