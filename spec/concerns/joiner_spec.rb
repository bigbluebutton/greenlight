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

describe Joiner do
  let(:controller) { FakesController.new }

  before do
    class FakesController < ApplicationController
      include Joiner
      def init(room)
        @room = room
        @settings = Setting.all
      end
    end
    @user = create(:user)
    @room = @user.main_room
    @room.uid = 'xxxx'
    controller.init @room
    controller.request = ActionController::TestRequest.create(FakesController)
  end

  after do
    Object.send :remove_const, :FakesController
  end

  it "should properly configure moderator message with nil access code" do
    expect(controller.default_meeting_options[:moderator_message]).not_to include('Access Code:')
  end

  it "should properly configure moderator message with empty access code" do
    @room.access_code = ""
    expect(controller.default_meeting_options[:moderator_message]).not_to include('Access Code:')
  end

  it "should properly configure moderator message with access code" do
    @room.access_code = "1234"
    expect(controller.default_meeting_options).to include(moderator_message: include('Access Code: 1234'))
  end
end
