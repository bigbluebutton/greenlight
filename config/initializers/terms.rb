# Load terms and conditions.

terms = "#{Rails.root}/config/terms.txt"

Rails.configuration.terms = if File.exist?(terms)
  File.read(terms)
else
  false
end
