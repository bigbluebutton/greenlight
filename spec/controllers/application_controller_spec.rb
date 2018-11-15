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

describe ApplicationController, type: :controller do
  describe "Application Controller Tests" do
    before { allow(Rails.configuration).to receive(:recording_thumbnails).and_return(true) }
    before { allow(Rails.configuration).to receive(:bigbluebutton_endpoint).and_return(:defaultBBBendpoint) }
    before { allow(Rails.configuration).to receive(:bigbluebutton_endpoint_default).and_return(:defaultBBBendpoint) }

    it "verifies if recording thumnails exist" do
      expect(controller.recording_thumbnails?).to eq(true)
    end

    it "verifies if bigbluebutton endpoint is default" do
      expect(controller.bigbluebutton_endpoint_default?).to eq(true)
    end

    it "Returns meeting name limit" do
      expect(controller.meeting_name_limit).to eq(90)
    end

    it "Returns user name limit" do
      expect(controller.user_name_limit).to eq(32)
    end

    it "Returns relative root" do
      expect(controller.relative_root).to eq("")
    end

    it "should return the right user locales" do
      expect(controller.user_locale("عربى")).to eq(:ar)
      expect(controller.user_locale("English")).to eq(:en)
      expect(controller.user_locale("Français")).to eq(:fr)
      expect(controller.user_locale("Deutsche")).to eq(:de)
      expect(controller.user_locale("Ελληνικά")).to eq(:el)
      expect(controller.user_locale("Portuguese (Brazil)")).to eq(:'pt-br')
      expect(controller.user_locale("Español")).to eq(:es)
    end
  end
end
