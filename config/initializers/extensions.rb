# config/initializers/extensions.rb
Dir["#{Rails.root}/lib/*.rb"].each { |file| require file }
