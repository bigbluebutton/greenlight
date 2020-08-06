# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

FactoryBot.define do
  factory :user do
    password = Faker::Internet.password(min_length: 8)
    provider { %w(google twitter).sample }
    uid { rand(10**8) }
    name { Faker::Name.first_name }
    username { Faker::Internet.user_name }
    email { Faker::Internet.email }
    password { password }
    password_confirmation { password }
    accepted_terms { true }
    email_verified { true }
    activated_at { Time.zone.now }
    role { set_role(:user) }
  end

  factory :room do
    name { Faker::Games::Pokemon.name }
    owner { create(:user) }
  end
end
