# frozen_string_literal: true

require 'bigbluebutton_api'

namespace :admin do
  desc "Creates an administrator account"
  task :create, [:name, :email, :password, :role] => :environment do |_task, args|
    u = {
      name: args[:name] || 'Administrator',
      password: args[:password] || Rails.configuration.admin_password_default,
      email: args[:email] || 'admin@example.com',
    }
    u[:email].prepend "superadmin-" if args[:role] == "super_admin"

    admin = User.find_by(email: u[:email])

    # Create administrator account if it doesn't exist
    unless admin
      admin = User.create(name: u[:name], email: u[:email], password: u[:password],
        password_confirmation: u[:password], provider: 'greenlight', email_verified: true)

      if args[:role] == "super_admin"
        admin.remove_role(:user)
        admin.add_role(:super_admin)
      else
        admin.add_role(:admin)
      end
    end
    puts "Administrator account succesfully created."
    puts "Email: #{u[:email]}"
    puts "Password: #{u[:password]}"
    puts "PLEASE CHANGE YOUR PASSWORD IMMEDIATELY" if u[:password] == Rails.configuration.admin_password_default
  end
end
