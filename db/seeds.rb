# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin = User.create(name: "Administrator", email: "admin@admin.com", password: "administrator",
                    password_confirmation: "administrator", provider: 'greenlight', email_verified: true)
admin.add_role :admin

if User.where(name: "Administrator").exists?
  puts "Administrator account succesfully created."
  puts "Email: admin@admin.com"
  puts "Password: administrator"
  puts "PLEASE CHANGE YOUR PASSWORD IMMEDIATELY"
end
