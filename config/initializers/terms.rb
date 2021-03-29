# frozen_string_literal: true

# Load terms and conditions.

terms = "#{Rails.root}/config/terms.md"

Rails.configuration.terms = if File.exist?(terms)
  File.read(terms)
else
  false
end
