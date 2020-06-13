# frozen_string_literal: true

require 'bigbluebutton_api'

namespace :user do
  desc "Creates a user account"
  task :create, [:name, :email, :password, :role, :provider] => :environment do |_task, args|
    u = {
      name: args[:name],
      password: args[:password],
      email: args[:email],
      role: args[:role] || "user",
      provider: args[:provider] || "greenlight"
    }

    if u[:role] == "admin"
      # Set default variables
      u[:name] = "Administrator" if u[:name].blank?
      u[:password] = Rails.configuration.admin_password_default if u[:password].blank?
      u[:email] = "admin@example.com" if u[:email].blank?
    elsif u[:name].blank? || u[:password].blank? || u[:email].blank?
      # Check that all fields exist
      puts "Missing Arguments"
      exit
    end

    # Create the default roles if not already created
    Role.create_default_roles(u[:provider]) if Role.where(provider: u[:provider]).count.zero?

    unless Role.exists?(name: u[:role], provider: u[:provider])
      puts "Invalid Role - Role does not exist"
      exit
    end

    u[:email].prepend "superadmin-" if args[:role] == "super_admin"

    # Create account if it doesn't exist
    if !User.exists?(email: u[:email], provider: u[:provider])
      user = User.create(name: u[:name], email: u[:email], password: u[:password],
        provider: u[:provider], email_verified: true, accepted_terms: true)

      unless user.valid?
        puts "Invalid Arguments"
        puts user.errors.messages
        exit
      end

      user.set_role(u[:role])

      puts "Account succesfully created."
      puts "Email: #{u[:email]}"
      puts "Password: #{u[:password]}"
      puts "Role: #{u[:role]}"
      puts "PLEASE CHANGE YOUR PASSWORD IMMEDIATELY" if u[:password] == Rails.configuration.admin_password_default
    else
      puts "Account with that email already exists"
      puts "Email: #{u[:email]}"
    end
  end
end
