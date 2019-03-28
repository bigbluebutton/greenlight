# frozen_string_literal: true

namespace :admin do
  task create: :environment do
    # Create administrator account if it doesn't exist
    unless User.where(email: "admin@admin.com").exists?
      admin = User.create(name: "Administrator", email: "admin@admin.com", password: "administrator",
                          password_confirmation: "administrator", provider: 'greenlight', email_verified: true)
      admin.add_role :admin

      if User.where(email: "admin@admin.com").exists?
        puts "Administrator account succesfully created."
        puts "Email: admin@admin.com"
        puts "Password: administrator"
        puts "PLEASE CHANGE YOUR PASSWORD IMMEDIATELY"
      end
    end
  end
end
