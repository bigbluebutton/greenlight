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

FactoryBot.define do
  factory :recording do
    room
    name { Faker::Educator.course_name }
    record_id { Faker::Internet.uuid }
    visibility { Recording::VISIBILITIES[:unpublished] }
    length { Faker::Number.within(range: 1..60) }
    participants { Faker::Number.within(range: 1..100) }
    recorded_at { Faker::Time.between(from: 2.days.ago, to: Time.zone.now) }

    after(:create) do |recording|
      create(:format, recording:)
    end
  end
end
