# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

User.create(
  name: 'Administrator',
  email: "admin@admin.com",
  password: 'Administrator1!',
  password_confirmation: 'Administrator1!',
  provider: 'greenlight',
  language: 'en',
  role: Role.find_by(name: 'Administrator')
)

puts "Successfully created an administrator account"
puts "email: admin@admin.com"
puts "password: Administrator1!"
puts "Sign up using your personal email and then promote that account using this administrator"
puts "Once you've promoted that account, this admin account must be deleted"