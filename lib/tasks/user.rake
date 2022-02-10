# frozen_string_literal: true

require 'bigbluebutton_api'

namespace :user do
  desc "Creates a user account"
  task :create, [:name, :email, :password, :role, :validate, :provider] => :environment do |_task, args|
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
      puts red "Missing Arguments"
      exit 2 # 2 for missing arguments
    end

    # Create the default roles if not already created
    Role.create_default_roles(u[:provider]) if Role.where(provider: u[:provider]).count.zero?

    unless Role.exists?(name: u[:role], provider: u[:provider])
      puts red "Invalid Role - Role does not exist"
      exit 3 # 3 for invalid Role.
    end

    u[:email].prepend "superadmin-" if args[:role] == "super_admin"

    # Create account if it doesn't exist
    if User.exists?(email: u[:email], provider: u[:provider])
      puts red "  Account with that email already exists"
      puts yellow "   Email: #{u[:email]}"
      exit 4 # 4 for email in use.
    else
      validation = args[:validate] || "true"
      user = User.new(name: u[:name], email: u[:email], password: u[:password],
      provider: u[:provider], email_verified: true, accepted_terms: true)

      unless user.save(validate: validation == "true") && user.valid?
        puts red "Invalid Arguments"
        puts yellow user.errors.messages
        if user.errors.include? :password
          puts green " The password must:"
          puts cyan "    1. Be 8 charachters in length."
          puts cyan "    2. Have at least 1 lowercase letter."
          puts cyan "    3. Have at least 1 upercase letter."
          puts cyan "    4. Have at least 1 digit."
          puts cyan "    5. Have at least 1 non-alphanumeric character"
        end
        exit 5 # 5 for invalid User.
      end

      user.set_role(u[:role])

      puts green "  Account successfully created."
      puts cyan "   Email: #{u[:email]}"
      puts cyan "   Password: #{u[:password]}"
      puts cyan "   Role: #{u[:role]}"
      puts yellow " PLEASE CHANGE YOUR PASSWORD IMMEDIATELY" if u[:password] == Rails.configuration.admin_password_default
    end
  end

  task :social_uid, [:provider] => :environment do |_task, args|
    args.with_defaults(provider: "greenlight")

    User.where(provider: args[:provider]).each do |user|
      if user.update(social_uid: "#{args[:provider]}:#{user.email}")
        puts green "Updated #{user.email} to #{args[:provider]}:#{user.email}"
      end
    end
  end
end
