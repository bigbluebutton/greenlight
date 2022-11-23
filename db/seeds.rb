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
  email: 'admin@admin.com',
  password: 'Administrator1!',
  provider: 'greenlight',
  language: 'en',
  role: Role.find_by(name: 'Administrator'),
  verified: true
)

Rails.logger.debug 'Successfully created an administrator account'
Rails.logger.debug 'email: admin@admin.com'
Rails.logger.debug 'password: Administrator1!'
Rails.logger.debug 'Sign up using your personal email and then promote that account using this administrator'
Rails.logger.debug "Once you've promoted that account, this admin account must be deleted"
