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

require "rails_helper"

describe Role, type: :model do
    it "should return duplicate if role name is in reserved role names" do
        expect(Role.duplicate_name("admin", "greenlight")).to eq(true)
    end

    it "should return duplicate if role name matched another" do
        Role.create(name: "test", provider: "greenlight")
        expect(Role.duplicate_name("test", "greenlight")).to eq(true)
    end

    it "should return false role name doesn't exist" do
        Role.create(name: "test", provider: "greenlight")
        expect(Role.duplicate_name("test1", "greenlight")).to eq(false)
    end
end
