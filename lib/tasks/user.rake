# frozen_string_literal: true

require 'bigbluebutton_api'

namespace :user do
  desc "Creates a user account"
  
  # added first name and lastname
  task :create, [:firstname, :laststname, :email, :mobile, :password, :role, :provider] => :environment do |_task, args|
    u = {
      firstname: args[:firstname],
      lastname: args[:laststname],
      name: "#{args[:firstname]}  #{args[:laststname]}",
      email: args[:email],
      mobile: args[:mobile],
      password: args[:password],
      role: args[:role] || "user",
      provider: args[:provider] || "greenlight"

    }

    if u[:role] == "admin"
      # Set default variables
      u[:firstname] = "Administrator" if u[:firstname].blank?
      u[:lastname] = "lastname" if u[:lastname].blank?
      u[:name] = "#{args[:firstname]}  #{args[:laststname]}" if u[:name].blank?
      u[:mobile] = "9999999999" if u[:mobile].blank?
      u[:password] = Rails.configuration.admin_password_default if u[:password].blank?
      u[:email] = "admin@example.com" if u[:email].blank?
    elsif u[:firstname].blank? || u[:lastname].blank? || u[:password].blank? || u[:email].blank? || u[:mobile].blank?
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
    if User.exists?(email: u[:email], provider: u[:provider])
      puts "Account with that email already exists"
      puts "Email: #{u[:email]}"
    else
      user = User.create(name: u[:name], firstname: u[:firstname],lastname: u[:lastname], email: u[:email], mobile: u[:mobile], password: u[:password],
        provider: u[:provider], email_verified: true, accepted_terms: true)

      unless user.valid?
        puts "Invalid Arguments"
        puts user.firstname
        puts user.errors.messages
        exit
      end

      user.set_role(u[:role])

      puts "Account successfully created."
      puts "Email: #{u[:email]}"
      puts "Password: #{u[:password]}"
      puts "Role: #{u[:role]}"
      puts "PLEASE CHANGE YOUR PASSWORD IMMEDIATELY" if u[:password] == Rails.configuration.admin_password_default
    end
  end
end
