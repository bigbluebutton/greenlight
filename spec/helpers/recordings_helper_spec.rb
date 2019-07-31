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

describe RecordingsHelper do
  describe "#recording_date" do
    it "formats the date" do
      date = DateTime.parse("2019-03-28 19:35:15 UTC")
      expect(helper.recording_date(date)).to eql("March 28, 2019")
    end
  end

  describe "#recording_length" do
    it "returns the time if length > 60" do
      playbacks = [{ type: "test", length: 85 }]
      expect(helper.recording_length(playbacks)).to eql("1 h 25 min")
    end

    it "returns the time if length == 0" do
      playbacks = [{ type: "test", length: 0 }]
      expect(helper.recording_length(playbacks)).to eql("< 1 min")
    end

    it "returns the time if length between 0 and 60" do
      playbacks = [{ type: "test", length: 45 }]
      expect(helper.recording_length(playbacks)).to eql("45 min")
    end
  end
end
