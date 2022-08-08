# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require 'faker'

50.times do |user|
  User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    provider: 'greenlight',
    password: 'password',
    password_confirmation: 'password',
    language: 'en', role_id: 2
  )
end
