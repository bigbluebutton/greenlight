# frozen_string_literal: true

require 'bigbluebutton_api'

namespace :admin do
  task create: :environment do
    u = {
      name: 'Administrator',
      password: Rails.configuration.admin_password_default,
      email: 'admin@example.com',
    }
    admin = User.where(email: u[:email])
    # Create administrator account if it doesn't exist
    unless admin
      admin = User.create(name: u[:name], email: u[:email], password: u[:password],
        password_confirmation: u[:password], provider: 'greenlight', email_verified: true)
      admin.add_role(:admin)
    end
    puts "Administrator account succesfully created."
    puts "Email: #{u[:email]}"
    puts "Password: #{u[:password]}"
    puts "PLEASE CHANGE YOUR PASSWORD IMMEDIATELY"
  end
end
