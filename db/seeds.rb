# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2022 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# Greenlight is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with Greenlight; if not, see <http://www.gnu.org/licenses/>.

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
